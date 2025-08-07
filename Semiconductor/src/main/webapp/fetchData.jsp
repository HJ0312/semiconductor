<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.json.simple.*, org.json.simple.parser.*" %>
<%@ page import="mvc.database.DBConnection" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    Connection conn = DBConnection.getConnection();
    String filterType = request.getParameter("filterType");
    String startTime = request.getParameter("startTime");
    String endTime = request.getParameter("endTime");

    StringBuilder sql = new StringBuilder("SELECT * FROM sensor_data");
    JSONArray jsonArray = new JSONArray();

    // 필터 조건 추가
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
    if (startTime != null && endTime != null && !startTime.isEmpty() && !endTime.isEmpty()) {
        conditions.add("timestamp BETWEEN ? AND ?");
    }

    // 조건이 있으면 WHERE 절 추가
    if (!conditions.isEmpty()) {
        sql.append(" WHERE ").append(String.join(" AND ", conditions));
    }
    sql.append(" ORDER BY timestamp DESC LIMIT 100");

    try (PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
        int paramIndex = 1;
        if (startTime != null && endTime != null && !startTime.isEmpty() && !endTime.isEmpty()) {
            pstmt.setString(paramIndex++, startTime.replace("T", " "));
            pstmt.setString(paramIndex++, endTime.replace("T", " "));
        }

        try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("temperature", rs.getFloat("temperature"));
                obj.put("noise", rs.getFloat("noise"));
                obj.put("gas", rs.getFloat("gas"));
                obj.put("timestamp", rs.getString("timestamp"));
                jsonArray.add(obj);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    out.print(jsonArray.toJSONString());
%>
