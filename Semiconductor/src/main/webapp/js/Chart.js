// 그래프를 업데이트하는 함수
function updateChart(data) {
    const labels = data.map((_, index) => index + 1); // X축 레이블 (측정 번호)
    const temperature = data.map(row => row.temperature);
    const noise = data.map(row => row.noise);
    const gas = data.map(row => row.gas);

    const ctx = document.getElementById('sensorChart').getContext('2d');

    // 기존 Chart.js 인스턴스 제거 (이미 있으면)
    if (window.sensorChart) {
        window.sensorChart.destroy();
    }

    // 새 Chart.js 인스턴스 생성
    window.sensorChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: '온도 (℃)',
                    data: temperature,
                    borderColor: 'rgba(255, 99, 132, 1)',
                    backgroundColor: 'rgba(255, 99, 132, 0.2)',
                    tension: 0.4,
                    pointRadius: 5,
                    pointHoverRadius: 7,
                },
                {
                    label: '소음 (db)',
                    data: noise,
                    borderColor: 'rgba(54, 162, 235, 1)',
                    backgroundColor: 'rgba(54, 162, 235, 0.2)',
                    tension: 0.4,
                    pointRadius: 5,
                    pointHoverRadius: 7,
                },
                {
                    label: '가스 농도',
                    data: gas,
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
}
