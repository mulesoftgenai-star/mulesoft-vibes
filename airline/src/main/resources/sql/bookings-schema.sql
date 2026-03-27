-- Bookings table for passenger flight bookings
-- This table stores passenger booking information needed for notifications

CREATE TABLE IF NOT EXISTS bookings (
    booking_id VARCHAR(50) PRIMARY KEY,
    flight_id INT NOT NULL,
    passenger_name VARCHAR(255) NOT NULL,
    passenger_email VARCHAR(255) NOT NULL,
    booking_date DATETIME NOT NULL DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED',
    seat_number VARCHAR(10),
    booking_reference VARCHAR(20),
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME NOT NULL DEFAULT GETDATE(),
    
    -- Foreign key to flights table (american table)
    FOREIGN KEY (flight_id) REFERENCES american(ID)
);

-- Index for efficient lookup by flight_id
CREATE INDEX IF NOT EXISTS idx_bookings_flight_id ON bookings(flight_id);

-- Index for efficient lookup by passenger email
CREATE INDEX IF NOT EXISTS idx_bookings_passenger_email ON bookings(passenger_email);

-- Index for efficient lookup by status
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);

-- Sample booking data for testing
INSERT INTO bookings (booking_id, flight_id, passenger_name, passenger_email, seat_number, booking_reference, status) 
VALUES 
    ('BK001', 1, 'John Smith', 'john.smith@email.com', '12A', 'AA123456', 'CONFIRMED'),
    ('BK002', 1, 'Jane Doe', 'jane.doe@email.com', '12B', 'AA123457', 'CONFIRMED'),
    ('BK003', 2, 'Mike Johnson', 'mike.johnson@email.com', '15C', 'AA123458', 'CONFIRMED'),
    ('BK004', 1, 'Sarah Wilson', 'sarah.wilson@email.com', '8A', 'AA123459', 'CONFIRMED'),
    ('BK005', 3, 'David Brown', 'david.brown@email.com', '20F', 'AA123460', 'CONFIRMED');