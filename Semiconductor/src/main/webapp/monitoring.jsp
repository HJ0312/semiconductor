<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, mvc.database.DBConnection" %>
<%@ page import="org.json.simple.*, org.json.simple.parser.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sensor Monitoring</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-annotation"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 0;
        }

        h2 {
            text-align: center;
            color: #333;
            font-size: 2rem;
            margin: 20px 0;
        }

        .chart-container {
            width: 90%;
            margin: 20px auto;
            padding: 20px;
            background-color: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
		.filter-container {
            width: 90%;
            margin: 20px auto;
            padding: 10px;
            display: flex;
            justify-content: space-between;
            background-color: #ffffff;
            border-radius: 10px;
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.2);
        }

        .filter-container input,
        .filter-container select {
            padding: 10px;
            font-size: 1rem;
            margin-right: 10px;
        }

        .filter-container button {
            padding: 10px 15px;
            font-size: 1rem;
            background-color: #007BFF;
            color: #fff;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
		
        .table-container {
            width: 90%;
            margin: 20px auto;
            padding: 20px;
            background-color: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            border: 1px solid #ddd;
            background-color: #ffffff;
        }

        th {
            background-color: #007BFF;
            color: white;
            font-weight: bold;
            text-align: center;
            padding: 12px 8px;
        }

        td {
            padding: 12px 8px;
            text-align: center;
            color: #555;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        tr:nth-child(odd) {
            background-color: #ffffff;
        }

        tr:hover {
            background-color: #f1f1f1;
            cursor: pointer;
        }

        .normal {
            background-color: #e0ffe0;
        }

        .warning {
            background-color: #fff8e0;
        }

        .danger {
            background-color: #ffe0e0;
            color: #d9534f;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <h2>실시간 센서 데이터 모니터링</h2>

  <form method="GET" action="searchResults.jsp" target="_blank">
    <label for="startTime">시작 시간:</label>
    <input type="datetime-local" id="startTime" name="startTime">
    <label for="endTime">종료 시간:</label>
    <input type="datetime-local" id="endTime" name="endTime">
    <label for="filterType">필터:</label>
    <select id="filterType" name="filterType">
        <option value="all">전체</option>
        <option value="normal">정상</option>
        <option value="warning">주의</option>
        <option value="danger">위험</option>
    </select>
    <button type="submit">검색</button>
</form>
    <div class="chart-container">
        <canvas id="sensorChart"></canvas>
    </div>    
    <div class="table-container">
        <table>
            <thead>
            <tr>
                <th>번호</th>
                <th>온도</th>
                <th>소음</th>
                <th>가스농도</th>
                <th>타임라인</th>
            </tr>
            </thead>
            <tbody>
                <%
                    // 데이터 필터 처리
                    String filterType = request.getParameter("filterType");
                    String sortBy = request.getParameter("sortBy");
                    String startTime = request.getParameter("startTime");
                    String endTime = request.getParameter("endTime");

                    Connection conn = DBConnection.getConnection();
                    String sql = "SELECT * FROM sensor_data";
                    if (filterType != null && filterType.equals("warning")) {
                        sql += " WHERE temperature > 100 OR noise > 150 OR gas > 1.5";
                    }
                    if (startTime != null && endTime != null && !startTime.isEmpty() && !endTime.isEmpty()) {
                        sql += (filterType != null && filterType.equals("warning") ? " AND" : " WHERE") +
                                " timestamp BETWEEN ? AND ?";
                    }
                    if (sortBy != null && sortBy.equals("danger")) {
                        sql += " ORDER BY (temperature > 100 OR noise > 150 OR gas > 1.5) DESC";
                    } else {
                        sql += " ORDER BY timestamp DESC";
                    }

                    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                        if (startTime != null && endTime != null && !startTime.isEmpty() && !endTime.isEmpty()) {
                            pstmt.setString(1, startTime.replace("T", " "));
                            pstmt.setString(2, endTime.replace("T", " "));
                        }
                        try (ResultSet rs = pstmt.executeQuery()) {
                            int index = 1;
                            boolean alert = false;
                            while (rs.next()) {
                                float temp = rs.getFloat("temperature");
                                float noise = rs.getFloat("noise");
                                float gas = rs.getFloat("gas");
                                Timestamp timestamp = rs.getTimestamp("timestamp");

                                String rowClass = "";
                                if (temp > 100 || noise > 150 || gas > 1.5) {
                                    rowClass = "danger";
                                    alert = true;
                                } else if (temp > 60 || noise > 100 || gas > 1.0) {
                                    rowClass = "warning";
                                }

                                out.println("<tr class='" + rowClass + "'>");
                                out.println("<td>" + (index++) + "</td>");
                                out.println("<td>" + temp + "℃</td>");
                                out.println("<td>" + noise + "db</td>");
                                out.println("<td>" + gas + "</td>");
                                out.println("<td>" + timestamp + "</td>");
                                out.println("</tr>");
                            }
                            
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                %>
            </tbody> 
        </table>
    </div>

<script>
    // 랜덤 데이터를 삽입하는 함수
    function insertData() {
        fetch('insertData.jsp')
            .then(response => response.text())
            .then(result => {
                console.log('데이터 삽입 완료:', result);
            })
            .catch(error => console.error('데이터 삽입 중 오류 발생:', error));
    }
 // 데이터를 가져와서 화면에 업데이트하는 함수
    function fetchAndUpdateData() {
    fetch('fetchData.jsp')
        .then(response => response.json())
        .then(data => {
            if (!data || data.length === 0) {
                console.error("No data found!");
                return;
            }

            function updateChart(data) {
                // 그래프 데이터 갱신
                const labels = data.map((item, index) => index + 1); // 측정 번호
                const temperatureData = data.map(item => item.temperature);
                const noiseData = data.map(item => item.noise);
                const gasData = data.map(item => item.gas);               
                
                sensorChart.data.labels = labels;
                sensorChart.data.datasets[0].data = temperatureData;
                sensorChart.data.datasets[1].data = noiseData;
                sensorChart.data.datasets[2].data = gasData;
                sensorChart.update(); // 그래프 갱신
            }

            function fetchData() {
                fetch('fetchData.jsp')
                    .then(response => response.json())
                    .then(data => {
                        console.log('Fetched Data:', data); // 데이터 구조 확인
                        updateChart(data); // 그래프 업데이트
                        updateTable(data);
                    })
                    .catch(error => console.error('Error fetching data:', error));
            }
            // *** 테이블 업데이트 ***
            const tableBody = document.querySelector('table tbody');
            tableBody.innerHTML = ''; // 기존 테이블 데이터 초기화
            function updateTable(data) {
                const tableBody = document.querySelector('table tbody');
                tableBody.innerHTML = ''; // 기존 데이터 초기화

                if (data && data.length > 0) {
                    data.forEach((row, index) => {
                        const tr = document.createElement('tr');
                        tr.innerHTML = `
                            <td>${index + 1}</td>
                            <td>${row.temperature}℃</td>
                            <td>${row.noise}db</td>
                            <td>${row.gas}</td>
                            <td>${row.timestamp}</td>
                        `;
                        tableBody.appendChild(tr);
                    });
                } else {
                    console.warn("표시할 데이터가 없습니다.");
                }
            }
            console.log("테이블에 추가될 데이터:", data);

            data.forEach((row, index) => {
                const tr = document.createElement('tr');

                // 위험 수준에 따라 행의 클래스 적용
                let colorClass = "normal";
                if (row.temperature > 100 || row.noise > 150 || row.gas > 1.5) {
                    colorClass = "danger";
                } else if (row.temperature > 60 || row.noise > 100 || row.gas > 1.0) {
                    colorClass = "warning";
                }
                tr.className = colorClass;

                // 테이블 데이터 삽입
                tr.innerHTML = `
                    <td>${index + 1}</td>
                    <td>${row.temperature}℃</td>
                    <td>${row.noise}db</td>
                    <td>${row.gas}</td>
                    <td>${row.timestamp || '데이터 없음'}</td>
                `;

                tableBody.appendChild(tr);
            });
        })
        .catch(error => {
            console.error('Error fetching data:', error);
        });
}

    function updateChart(data) {
        const labels = Object.keys(data).map((_, i) => i + 1); // X축 레이블: 측정 번호
        const temperature = Object.values(data).map(row => row.temperature);
        const noise = Object.values(data).map(row => row.noise);
        const gas = Object.values(data).map(row => row.gas);
       
        sensorChart.data.labels = labels;
        sensorChart.data.datasets[0].data = temperatureData;
        sensorChart.data.datasets[1].data = noiseData;
        sensorChart.data.datasets[2].data = gasData;
        sensorChart.update(); // 그래프 갱신
    }

    // 페이지 로드 후 실행
    document.addEventListener('DOMContentLoaded', () => {      
        const ctx2 = document.getElementById('sensorChart').getContext('2d');
        window.sensorChart = new Chart(ctx2, {
            type: 'line',
            data: {
                labels: [], // 초기 레이블
                datasets: [
                    {
                        label: '온도 (℃)',
                        data: [],
                        borderColor: 'rgba(255, 99, 132, 1)',
                        backgroundColor: 'rgba(255, 99, 132, 0.2)',
                        tension: 0.4,
                        pointRadius: 5,
                        pointHoverRadius: 7,
                    },
                    {
                        label: '소음 (db)',
                        data: [],
                        borderColor: 'rgba(54, 162, 235, 1)',
                        backgroundColor: 'rgba(54, 162, 235, 0.2)',
                        tension: 0.4,
                        pointRadius: 5,
                        pointHoverRadius: 7,
                    },
                    {
                        label: '가스 농도',
                        data: [],
                        borderColor: 'rgba(75, 192, 192, 1)',
                        backgroundColor: 'rgba(75, 192, 192, 0.2)',
                        tension: 0.4,
                        pointRadius: 5,
                        pointHoverRadius: 7,
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        position: 'top',
                    }
                },
                scales: {
                    x: {
                        title: {
                            display: true,
                            text: '측정 번호',
                        }
                    },
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: '측정 값',
                        }
                    }
                }
            }
        });
        setInterval(() => {
            insertData();
            fetchAndUpdateData();
        }, 5000);  // 5초마다 데이터 삽입 및 갱신
    });
</script>
</body>
<script src="js/fetchData.js"></script>
<script src="js/Chart.js"></script>

</html>
