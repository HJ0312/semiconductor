package mvc.controller;

import com.google.gson.Gson;
import dao.SensorDataDAO;
import dto.SensorData;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;

@WebServlet("/monitoring")
public class MonitoringController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 요청으로부터 JSON 데이터를 읽음
        StringBuilder jsonBuffer = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuffer.append(line);
            }
        }

        // JSON 데이터를 SensorData 객체로 변환
        Gson gson = new Gson();
        SensorData sensorData = gson.fromJson(jsonBuffer.toString(), SensorData.class);

        // 데이터베이스에 저장
        SensorDataDAO sensorDataDAO = new SensorDataDAO();
        boolean isInserted = sensorDataDAO.insertSensorData(sensorData);

        // 결과를 클라이언트로 응답
        response.setContentType("application/json; charset=UTF-8");
        if (isInserted) {
            response.getWriter().write("{\"message\": \"Data inserted successfully!\"}");
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"message\": \"Failed to insert data.\"}");
        }
    }
}
