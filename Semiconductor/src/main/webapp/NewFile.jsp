<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, mvc.database.DBConnection" %>
<%@ page import="org.json.simple.*, org.json.simple.parser.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sensor Monitoring</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-annotation"></script> <!-- Annotation 플러그인 -->
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f8f9fa; /* 밝은 배경 */
            color: #333; /* 기본 텍스트 색상 */
            margin: 20px;
            line-height: 1.6;
        }
        h2 {
            text-align: center;
            color: #4CAF50; /* 헤더 색상 */
            margin-bottom: 20px;
        }
        table {
            width: 90%;
            margin: 20px auto;
            border-collapse: collapse;
            background: white;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            border-radius: 5px;
            overflow: hidden;
        }
        th {
            background-color: #4CAF50; /* 헤더 색상 */
            color: white;
            font-weight: bold;
            padding: 10px;
        }
        td {
            padding: 10px;
            text-align: center;
            font-size: 14px;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2; /* 교차 색상 */
        }
        .normal {
            background-color: #adff2f; /* 정상 */
        }
        .warning {
            background-color: #ffff00; /* 경고 */
        }
        .danger {
            background-color: #ff4500; /* 위험 */
            color: white;
            font-weight: bold;
        }
        #chart-container {
            width: 90%;
            max-width: 1000px; /* 최대 너비 확대 */
            margin: 40px auto; /* 상하 여백 추가 */
            background: white;
            padding: 30px; /* 내부 패딩 증가 */
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
        }
        canvas {
            display: block;
            margin: 0 auto;
            max-height: 600px; /* 그래프 최대 높이 */
            max-width: 100%; /* 그래프 최대 너비 */
        }
    </style>
</head>
<body>
    <h2>실시간 센서 데이터 모니터링</h2>

    <!-- 데이터 테이블 -->
    <table>
        <tr>
            <th>번호</th>
            <th>온도 (℃)</th>
            <th>소음 (db)</th>
            <th>가스 농도</th>
            <th>타임라인</th>
        </tr>
        <%
            Connection conn = DBConnection.getConnection();
            String sql = "SELECT * FROM sensor_data ORDER BY timestamp DESC LIMIT 10";
            try (PreparedStatement pstmt = conn.prepareStatement(sql);
                 ResultSet rs = pstmt.executeQuery()) {
                int index = 1;
                while (rs.next()) {
                    float temp = rs.getFloat("temperature");
                    float noise = rs.getFloat("noise");
                    float gas = rs.getFloat("gas");
                    String colorClass = "normal";
                    if (temp > 100 || noise > 150 || gas > 1.5) colorClass = "danger";
                    else if (temp > 60 || noise > 100 || gas > 1.0) colorClass = "warning";

                    Timestamp dbTimestamp = rs.getTimestamp("timestamp");
                    TimeZone tz = TimeZone.getTimeZone("Asia/Seoul");
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    sdf.setTimeZone(tz);
                    String formattedTime = sdf.format(dbTimestamp);
        %>
        <tr class="<%=colorClass%>">
            <td><%=index++%></td>
            <td><%=temp%>℃</td>
            <td><%=noise%>db</td>
            <td><%=gas%></td>
            <td><%=formattedTime%></td>
        </tr>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>
    </table>

    <!-- 그래프 출력 -->
    <div id="chart-container">
        <canvas id="sensorChart"></canvas>
    </div>
    <script>
        fetch('fetchData.jsp')
            .then(response => response.json())
            .then(data => {
                const labels = data.map((_, i) => i + 1);
                const temperature = data.map(row => row.temperature);
                const noise = data.map(row => row.noise);
                const gas = data.map(row => row.gas);

                const ctx = document.getElementById('sensorChart').getContext('2d');
                new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: labels,
                        datasets: [
                            { 
                                label: '온도 (℃)', 
                                data: temperature, 
                                borderColor: 'rgba(255, 99, 132, 1)', 
                                backgroundColor: 'rgba(255, 99, 132, 0.2)', 
                                tension: 0.4 
                            },
                            { 
                                label: '소음 (db)', 
                                data: noise, 
                                borderColor: 'rgba(54, 162, 235, 1)', 
                                backgroundColor: 'rgba(54, 162, 235, 0.2)', 
                                tension: 0.4 
                            },
                            { 
                                label: '가스 농도', 
                                data: gas, 
                                borderColor: 'rgba(75, 192, 192, 1)', 
                                backgroundColor: 'rgba(75, 192, 192, 0.2)', 
                                tension: 0.4 
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false, /* 그래프 비율 고정 해제 */
                        plugins: {
                            annotation: {
                                annotations: {
                                    line1: {
                                        type: 'line',
                                        yMin: 100,
                                        yMax: 100,
                                        borderColor: 'red',
                                        borderWidth: 2,
                                        label: {
                                            content: '온도 경고 기준 (100℃)',
                                            enabled: true,
                                            position: 'end'
                                        }
                                    },
                                    line2: {
                                        type: 'line',
                                        yMin: 150,
                                        yMax: 150,
                                        borderColor: 'red',
                                        borderWidth: 2,
                                        label: {
                                            content: '소음 경고 기준 (150db)',
                                            enabled: true,
                                            position: 'end'
                                        }
                                    },
                                    line3: {
                                        type: 'line',
                                        yMin: 1.5,
                                        yMax: 1.5,
                                        borderColor: 'red',
                                        borderWidth: 2,
                                        label: {
                                            content: '가스 농도 경고 기준',
                                            enabled: true,
                                            position: 'end'
                                        }
                                    }
                                }
                            }
                        },
                        scales: {
                            x: {
                                title: {
                                    display: true,
                                    text: '측정 번호',
                                    color: '#333',
                                    font: {
                                        size: 14,
                                        weight: 'bold'
                                    }
                                }
                            },
                            y: {
                                beginAtZero: true,
                                title: {
                                    display: true,
                                    text: '측정 값',
                                    color: '#333',
                                    font: {
                                        size: 14,
                                        weight: 'bold'
                                    }
                                }
                            }
                        }
                    }
                });
            });
    </script>
</body>
</html>
