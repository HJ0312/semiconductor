<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, mvc.database.DBConnection" %>

<%
    String temperature = request.getParameter("temperature");
    String noise = request.getParameter("noise");
    String gas = request.getParameter("gas");

    out.println("Received Data -> Temperature: " + temperature + ", Noise: " + noise + ", Gas: " + gas);

    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        if (conn != null) {
            out.println("Database Connected Successfully");

            String sql = "INSERT INTO sensor_data (temperature, noise, gas) VALUES (?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setFloat(1, Float.parseFloat(temperature));
                pstmt.setFloat(2, Float.parseFloat(noise));
                pstmt.setFloat(3, Float.parseFloat(gas));

                int rowsInserted = pstmt.executeUpdate();
                out.println("Rows Inserted: " + rowsInserted);

                response.sendRedirect("monitoring.jsp");
            }
        } else {
            out.println("Database Connection Failed");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("Error: " + e.getMessage());
    }
%>
