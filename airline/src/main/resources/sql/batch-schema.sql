-- Enhanced Flight Records Table for Batch Processing
CREATE TABLE IF NOT EXISTS flights (
    flight_id VARCHAR(36) PRIMARY KEY,
    flight_number VARCHAR(20) NOT NULL,
    airline VARCHAR(100) DEFAULT 'American Airlines',
    departure_airport VARCHAR(10) NOT NULL,
    departure_city VARCHAR(100),
    departure_scheduled_time TIMESTAMP NOT NULL,
    departure_actual_time TIMESTAMP NULL,
    departure_gate VARCHAR(10) NULL,
    departure_terminal VARCHAR(10) NULL,
    arrival_airport VARCHAR(10) NOT NULL,
    arrival_city VARCHAR(100),
    arrival_scheduled_time TIMESTAMP NOT NULL,
    arrival_actual_time TIMESTAMP NULL,
    arrival_gate VARCHAR(10) NULL,
    arrival_terminal VARCHAR(10) NULL,
    aircraft_type VARCHAR(50),
    aircraft_registration VARCHAR(20),
    aircraft_capacity INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'SCHEDULED',
    price DECIMAL(10,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'USD',
    duration VARCHAR(10),
    distance INTEGER DEFAULT 0,
    batch_id VARCHAR(36),
    record_index INTEGER,
    processing_timestamp TIMESTAMP,
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_batch_id (batch_id),
    INDEX idx_flight_number (flight_number),
    INDEX idx_status (status),
    INDEX idx_processing_timestamp (processing_timestamp)
);

-- Batch Errors Table for Failed Records Tracking
CREATE TABLE IF NOT EXISTS batch_errors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    batch_id VARCHAR(36) NOT NULL,
    record_index INTEGER,
    flight_number VARCHAR(20),
    departure_airport VARCHAR(10),
    arrival_airport VARCHAR(10),
    error_type VARCHAR(50),
    error_reason TEXT,
    failed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_data JSON,
    INDEX idx_batch_errors_batch_id (batch_id),
    INDEX idx_batch_errors_failed_at (failed_at)
);

-- Batch Processing Summary Table
CREATE TABLE IF NOT EXISTS batch_summary (
    id INT AUTO_INCREMENT PRIMARY KEY,
    batch_id VARCHAR(36) UNIQUE NOT NULL,
    processing_start_time TIMESTAMP,
    processing_end_time TIMESTAMP,
    total_records INTEGER DEFAULT 0,
    successful_records INTEGER DEFAULT 0,
    failed_records INTEGER DEFAULT 0,
    processing_duration_seconds DECIMAL(10,2),
    success_rate DECIMAL(5,2),
    status VARCHAR(50),
    email_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_batch_summary_batch_id (batch_id),
    INDEX idx_batch_summary_status (status),
    INDEX idx_batch_summary_created_at (created_at)
);