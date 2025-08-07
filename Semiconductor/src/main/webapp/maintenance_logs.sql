CREATE TABLE maintenance_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    issue VARCHAR(255),
    resolved BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME
);
