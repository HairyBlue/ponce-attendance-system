-- Create the schema if it doesn't exist, with Unicode defaults.
-- CREATE SCHEMA IF NOT EXISTS attendance_system 
--   DEFAULT CHARACTER SET utf8mb4 
--   COLLATE utf8mb4_unicode_ci;

-- create Database IF NOT EXISTS attendance_system;

-- USE attendance_system;

-- ========================================
-- Create Departments Table
-- ========================================
CREATE TABLE IF NOT EXISTS departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Create Admins Table
-- ========================================
CREATE TABLE IF NOT EXISTS admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL  -- Store hashed passwords here
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Create Staff Table
-- ========================================
CREATE TABLE IF NOT EXISTS staff (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,  -- Store hashed passwords here
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Create Users Table
-- ========================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,  -- Store hashed passwords here
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Create Events Table (with a new deadline column)
-- ========================================
CREATE TABLE IF NOT EXISTS events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    deadline DATETIME DEFAULT NULL,  -- New column to store the event deadline
    created_by INT,
    department_id INT,
    FOREIGN KEY (created_by) REFERENCES staff(id) ON DELETE SET NULL,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Create Attendance Table with improved check constraint for student_id
-- ========================================
CREATE TABLE IF NOT EXISTS attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    student_id VARCHAR(11),
    event_id INT NOT NULL,
    department_id INT,
    attended_on DATE NOT NULL,
    CONSTRAINT chk_student_id_format CHECK (
      student_id REGEXP '^(?:[0-9]{4}-[0-9]{4}-[0-9]|[0-9]{6})$'
    ),

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- Drop the student_list table if it already exists
-- ========================================
-- DROP TABLE IF EXISTS student_list;

-- -- ========================================
-- -- Create the student_list Table with the new year_level column
-- -- ========================================
-- CREATE TABLE student_list (
--     student_id VARCHAR(11) PRIMARY KEY,  -- Student ID (e.g., 1234-5678-9 or 123456)
--     name VARCHAR(100) NOT NULL,          -- Student's full name
--     course VARCHAR(100) NOT NULL,        -- Course the student is enrolled in
--     year_level INT NOT NULL              -- Student's year level (e.g., 1, 2, 3, 4)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert Departments
INSERT INTO departments (name) VALUES ('CSG'), ('CABE'), ('CCIS'), ('CEDAS'), ('COE'), ('CHS');

-- Insert Admin
INSERT INTO admin (email, password) VALUES ('admin@admin.com', '$2y$10$ioLIwmlasvs5XvE8ftCCVuHIpsLABPC0tYOceNjTJLd57USNzE1rO');