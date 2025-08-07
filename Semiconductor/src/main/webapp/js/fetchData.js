function fetchData() {
    fetch('fetchData.jsp') // JSP 파일에서 데이터 가져오기
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            console.log('Fetched Data:', data);
            if (!Array.isArray(data)) {
                throw new Error('받아온 데이터가 배열이 아닙니다.');
            }
            updateChart(data); // 그래프 업데이트
            updateTable(data); // 테이블 업데이트
        })
        .catch(error => console.error('Error fetching data:', error));
}

function updateTable(data) {
    const tableBody = document.querySelector('table tbody');
    if (!tableBody) {
        console.error('테이블 <tbody>를 찾을 수 없습니다.');
        return;
    }
    tableBody.innerHTML = ''; // 기존 테이블 초기화

    data.forEach((row, index) => {
        const tr = document.createElement('tr');

        let rowClass = "normal";
        if (row.temperature > 100 || row.noise > 150 || row.gas > 1.5) {
            rowClass = "danger";
        } else if (row.temperature > 60 || row.noise > 100 || row.gas > 1.0) {
            rowClass = "warning";
        }
        tr.className = rowClass;

        tr.innerHTML = `
            <td>${index + 1}</td>
            <td>${row.temperature || 'N/A'}℃</td>
            <td>${row.noise || 'N/A'}db</td>
            <td>${row.gas || 'N/A'}</td>
            <td>${row.timestamp || '데이터 없음'}</td>
        `;
        tableBody.appendChild(tr);
    });
}
// 5초마다 데이터를 가져오는 기능
document.addEventListener('DOMContentLoaded', () => {
    fetchData(); // 처음 실행
    setInterval(fetchData, 5000); // 5초마다 실행
});