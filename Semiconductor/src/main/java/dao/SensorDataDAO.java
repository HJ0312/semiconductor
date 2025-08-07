package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import dto.SensorData;
import mvc.database.DBConnection;

public class SensorDataDAO {

    private Connection conn;

    public SensorDataDAO() {
        conn = DBConnection.getConnection();
    }

    // Create: Insert sensor data into the database
    public boolean insertSensorData(SensorData data) {
        String sql = "INSERT INTO sensor_data (sensor_type, value) VALUES (?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, data.getSensorType());
            pstmt.setFloat(2, data.getValue());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Read: Retrieve all sensor data
    public List<SensorData> getAllSensorData() {
        List<SensorData> dataList = new ArrayList<>();
        String sql = "SELECT * FROM sensor_data ORDER BY timestamp DESC";
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                SensorData data = new SensorData(
                    rs.getInt("id"),
                    rs.getString("sensor_type"),
                    rs.getFloat("value"),
                    rs.getTimestamp("timestamp")
                );
                dataList.add(data);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return dataList;
    }

    // Delete: Remove sensor data older than a specific date
    public boolean deleteOldSensorData(String date) {
        String sql = "DELETE FROM sensor_data WHERE timestamp < ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, date);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
