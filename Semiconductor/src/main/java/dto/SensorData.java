package dto;

import java.sql.Timestamp;

public class SensorData {
    private int id;
    private String sensorType;
    private float value;
    private Timestamp timestamp;

    public SensorData(int id, String sensorType, float value, Timestamp timestamp) {
        this.id = id;
        this.sensorType = sensorType;
        this.value = value;
        this.timestamp = timestamp;
    }

    public int getId() {
        return id;
    }

    public String getSensorType() {
        return sensorType;
    }

    public float getValue() {
        return value;
    }

    public Timestamp getTimestamp() {
        return timestamp;
    }
}
