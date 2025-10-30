-- Jasmin SMS CDR Database Initialization Script
-- This script creates the submit_log table for storing SMS submission records

USE sms;

-- Create submit_log table
CREATE TABLE IF NOT EXISTS submit_log (
    `msgid`            VARCHAR(45) PRIMARY KEY,
    `source_connector` VARCHAR(15),
    `routed_cid`       VARCHAR(30),
    `source_addr`      VARCHAR(40),
    `destination_addr` VARCHAR(40) NOT NULL CHECK (`destination_addr` <> ''),
    `rate`             DECIMAL(12, 7),
    `pdu_count`        TINYINT(3) DEFAULT 1,
    `short_message`    BLOB,
    `binary_message`   BLOB,
    `status`           VARCHAR(25) NOT NULL CHECK (`status` <> ''),
    `uid`              VARCHAR(15) NOT NULL CHECK (`uid` <> ''),
    `trials`           TINYINT(4) DEFAULT 1,
    `created_at`       DATETIME NOT NULL,
    `status_at`        DATETIME NOT NULL,
    INDEX `sms_log_1` (`status`),
    INDEX `sms_log_2` (`uid`),
    INDEX `sms_log_3` (`routed_cid`),
    INDEX `sms_log_4` (`created_at`),
    INDEX `sms_log_5` (`created_at`, `uid`),
    INDEX `sms_log_6` (`created_at`, `uid`, `status`)
) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Display table structure
DESCRIBE submit_log;

-- Display success message
SELECT 'Database initialized successfully!' AS message;
