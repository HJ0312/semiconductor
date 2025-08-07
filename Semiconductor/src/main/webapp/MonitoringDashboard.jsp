<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>모니터링 대시보드</title>
    <link rel="stylesheet" href="resources/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
    <div class="container mt-4">
        <h1 class="text-center">모니터링 대시보드</h1>
        
        <!-- Sensor Data Table -->
        <h3>센서 데이터</h3>
        <table class="table table-bordered table-striped" id="sensorTable">
            <thead>
                <tr>
                    <th>아이디</th>
                    <th>센서 유형</th>
                    <th>값</th>
                    <th>시간</th>
                </tr>
            </thead>
            <tbody id="sensorTableBody">
                <!-- Initial data will be rendered here -->
            </tbody>
        </table>

        <!-- Sensor Data Chart -->
        <h3>실시간 데이터 차트</h3>
        <canvas id="sensorChart" width="400" height="200"></canvas>
    </div>

    <script>
        // Chart.js setup
        const ctx = document.getElementById('sensorChart').getContext('2d');
        const sensorChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [], // Timestamps
                datasets: [{
                    label: '센서 값',
                    data: [], // Values
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    borderColor: 'rgba(75, 192, 192, 1)',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                scales: {
                    x: {
                        title: {
                            display: true,
                            text: '시간'
                        }
                    },
                    y: {
                        title: {
                            display: true,
                            text: '값'
                        },
                        beginAtZero: true
                    }
                }
            }
        });

        // Function to update table and chart
        function updateDashboard() {
            $.ajax({
                url: "monitoring", // URL of the MonitoringController
                method: "GET",
                dataType: "json",
                success: function (response) {
                    // Update table
                    const tableBody = $("#sensorTableBody");
                    tableBody.empty(); // Clear existing rows
                    response.forEach(data => {
                        const row = `<tr>
                            <td>${data.id}</td>
                            <td>${data.sensorType}</td>
                            <td>${data.value}</td>
                            <td>${data.timestamp}</td>
                        </tr>`;
                        tableBody.append(row);
                    });

                    // Update chart
                    sensorChart.data.labels = response.map(data => data.timestamp);
                    sensorChart.data.datasets[0].data = response.map(data => data.value);
                    sensorChart.update();
                },
                error: function (xhr, status, error) {
                    console.error("데이터 가져오기 에러:", error);
                }
            });
        }

        // Periodically update the dashboard
        setInterval(updateDashboard, 5000); // Update every 5 seconds

        // Initial load
        updateDashboard();
    </script>
</body>
</html>
