-- MariaDB Setup Script for Note Taking App
-- Run this script as root user in MariaDB

-- Create the database
CREATE DATABASE IF NOT EXISTS noteapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create a dedicated user for the application
CREATE USER IF NOT EXISTS 'noteapp'@'localhost' IDENTIFIED BY 'NoteApp123!';

-- Grant all privileges on the noteapp database to the noteapp user
GRANT ALL PRIVILEGES ON noteapp.* TO 'noteapp'@'localhost';

-- Refresh privileges
FLUSH PRIVILEGES;

-- Show databases to confirm creation
SHOW DATABASES;

-- Show the created user
SELECT User, Host FROM mysql.user WHERE User = 'noteapp'; 