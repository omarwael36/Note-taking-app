-- Initialize the notes database schema
CREATE DATABASE IF NOT EXISTS noteapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE noteapp;

CREATE TABLE IF NOT EXISTS notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at)
);
