<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.Random" %>
<%@ page import="mvc.database.DBConnection" %>

<%
    // 랜덤 값을 생성하기 위해 Random 객체 생성
    Random random = new Random();

    // 랜덤 값 생성
    float temperature = 20 + random.nextFloat() * 130; // 온도 (20 ~ 150)
    float noise = 30 + random.nextFloat() * 170; // 소음 (30 ~ 200)
    float gas = (float) (0.5 + random.nextFloat() * 2.5); // 더블을 float으로 변환

    try (Connection conn = DBConnection.getConnection()) {
        // SQL 쿼리: 센서 데이터 삽입
        String sql = "INSERT INTO sensor_data (temperature, noise, gas) VALUES (?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);

        // 랜덤 값 삽입
       pstmt.setFloat(1, temperature);
        pstmt.setFloat(2, noise);
        pstmt.setFloat(3, gas);

        // 데이터 삽입 실행
        int result = pstmt.executeUpdate();

        if (result > 0) {
            // 삽입 성공 시 로그
            System.out.println("랜덤 데이터 삽입 성공!");
        } else {
            System.out.println("데이터 삽입 실패.");
        }

        pstmt.close();
    } catch (Exception e) {
        e.printStackTrace();
        System.out.println("오류 발생: " + e.getMessage());
    }
    
%>