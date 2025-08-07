<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="mvc.database.DBConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>검색 결과</title>
    <style>
        /* 기존 스타일 유지 */
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f9;
        }
        h2 {
            text-align: center;
            margin: 20px;
            color: #333;
        }
        .result-container {
            width: 90%;
            margin: 20px auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th {
            background-color: #007BFF;
            color: white;
            padding: 10px;
            text-align: center;
        }
        td {
            padding: 10px;
            text-align: center;
            color: #333;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        tr:nth-child(odd) {
            background-color: #fff;
        }
        tr:hover {
            background-color: #f1f1f1;
            cursor: pointer;
        }
        .danger {
            color: #d9534f;
            font-weight: bold;
        }
        .filter-label {
            text-align: center;
            font-size: 1.2rem;
            margin-bottom: 20px;
            color: #007BFF;
        }
    </style>
</head>
<body>
    <% 
        String filterType = request.getParameter("filterType");
        String startTime = request.getParameter("startTime");
        String endTime = request.getParameter("endTime");

        // 추가된 검색 조건
        String minTemp = request.getParameter("minTemp");
        String maxTemp = request.getParameter("maxTemp");
        String minNoise = request.getParameter("minNoise");
        String maxNoise = request.getParameter("maxNoise");
        String minGas = request.getParameter("minGas");
        String maxGas = request.getParameter("maxGas");

        Connection conn = DBConnection.getConnection();
        String sql = "SELECT * FROM sensor_data";
        List<String> conditions = new ArrayList<>();

        if (filterType != null && !filterType.equals("all")) {
            switch (filterType) {
                case "normal":
                    conditions.add("temperature <= 60 AND noise <= 100 AND gas <= 1.0");
                    break;
                case "warning":
                    conditions.add("(temperature > 60 AND temperature <= 100) OR (noise > 100 AND noise <= 150) OR (gas > 1.0 AND gas <= 1.5)");
                    break;
                case "danger":
                    conditions.add("temperature > 100 OR noise > 150 OR gas > 1.5");
                    break;
            }
        }

        // 개별 조건 추가
        if (minTemp != null && !minTemp.isEmpty()) conditions.add("temperature >= " + minTemp);
        if (maxTemp != null && !maxTemp.isEmpty()) conditions.add("temperature <= " + maxTemp);
        if (minNoise != null && !minNoise.isEmpty()) conditions.add("noise >= " + minNoise);
        if (maxNoise != null && !maxNoise.isEmpty()) conditions.add("noise <= " + maxNoise);
        if (minGas != null && !minGas.isEmpty()) conditions.add("gas >= " + minGas);
        if (maxGas != null && !maxGas.isEmpty()) conditions.add("gas <= " + maxGas);

        if (startTime != null && endTime != null && !startTime.isEmpty() && !endTime.isEmpty()) {
            conditions.add("timestamp BETWEEN ? AND ?");
        }

        if (!conditions.isEmpty()) {
            sql += " WHERE " + String.join(" AND ", conditions);
        }

        sql += " ORDER BY timestamp DESC";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            int paramIndex = 1;
            if (startTime != null && endTime != null && !startTime.isEmpty() && !endTime.isEmpty()) {
                pstmt.setString(paramIndex++, startTime.replace("T", " "));
                pstmt.setString(paramIndex++, endTime.replace("T", " "));
            }

            try (ResultSet rs = pstmt.executeQuery()) {
    %>
                <h2>검색 결과</h2>
                <div class="result-container">
                    <div class="filter-label">
                        선택된 필터: 
                        <%
                            if ("normal".equals(filterType)) {
                                out.print("정상");
                            } else if ("warning".equals(filterType)) {
                                out.print("주의");
                            } else if ("danger".equals(filterType)) {
                                out.print("위험");
                            } else {
                                out.print("전체");
                            }
                        %>
                    </div>
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
                            int index = 1;
                            while (rs.next()) {
                                float temp = rs.getFloat("temperature");
                                float noise = rs.getFloat("noise");
                                float gas = rs.getFloat("gas");
                                Timestamp timestamp = rs.getTimestamp("timestamp");

                                String rowClass = "";
                                if (temp > 100 || noise > 150 || gas > 1.5) {
                                    rowClass = "danger";
                                }
                        %>
                            <tr class="<%= rowClass %>">
                                <td><%= index++ %></td>
                                <td><%= temp %>℃</td>
                                <td><%= noise %>db</td>
                                <td><%= gas %></td>
                                <td><%= timestamp %></td>
                            </tr>
                        <% 
                            }
                        %>
                        </tbody>
                    </table>
                </div>
    <% 
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    %>
</body>
</html>
