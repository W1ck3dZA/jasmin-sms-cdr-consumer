# SMS CDR Consumer

A Docker-based SMS Call Detail Record (CDR) consumer service that integrates with Jasmin SMS Gateway, RabbitMQ, Redis, and MySQL.

## Overview

This service consumes SMS CDR messages from RabbitMQ queues, processes them, and stores the data in MySQL while using Redis for caching and state management.

## Project Structure

```
sms-cdr-consumer/
├── build-image.sh              # Docker image build script
├── push-image.sh               # Docker image push script
├── sms_cdr_consumer.py         # Main consumer application
├── config/
│   ├── Dockerfile              # Docker image definition
│   ├── jasmin.conf             # Jasmin SMS Gateway configuration
│   ├── amqp0-9-1.xml          # AMQP protocol specification
│   └── init.sql                # MySQL database initialization
└── samples/
    ├── docker-compose-sample.yml  # Sample Docker Compose setup
    └── send-sms.py                # Sample SMS sending script
```

## Prerequisites

- Docker
- Docker Compose (optional, for sample setup)
- Access to RabbitMQ, Redis, and MySQL instances
- Jasmin SMS Gateway with `publish_submit_sm_resp` activated in `jasmin.cfg`

## Quick Start

### 1. Build the Docker Image

```bash
./build-image.sh [IMAGE_NAME] [TAG]
```

**Examples:**
```bash
# Build with default name and tag (jasmin-sms-cdr-consumer:latest)
./build-image.sh

# Build with custom name and tag
./build-image.sh jasmin-sms-cdr-consumer v1.0.1
```

### 2. Run the Container

```bash
docker run -d \
  --name jasmin-sms-cdr-consumer \
  -e REDIS_HOST=your-redis-host \
  -e REDIS_PORT=6379 \
  -e MYSQL_HOST=your-mysql-host \
  -e MYSQL_PORT=3306 \
  -e MYSQL_USER=your-user \
  -e MYSQL_PASSWORD=your-password \
  -e MYSQL_DB=your-database \
  -e AMQP_HOST=your-rabbitmq-host \
  -e AMQP_PORT=5672 \
  -e AMQP_VHOST=/ \
  -e AMQP_USER=guest \
  -e AMQP_PASSWORD=guest \
  jasmin-sms-cdr-consumer:latest
```

### 3. Push to Registry (Optional)

```bash
./push-image.sh [IMAGE_NAME] [TAG] [REGISTRY]
```

**Examples:**
```bash
# Push to Docker Hub
./push-image.sh jasmin-sms-cdr-consumer latest

# Push to private registry
./push-image.sh jasmin-sms-cdr-consumer v1.0.0 registry.example.com
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `REDIS_HOST` | Redis server hostname | `localhost` |
| `REDIS_PORT` | Redis server port | `6379` |
| `MYSQL_HOST` | MySQL server hostname | `localhost` |
| `MYSQL_PORT` | MySQL server port | `3306` |
| `MYSQL_USER` | MySQL username | `user` |
| `MYSQL_PASSWORD` | MySQL password | `password` |
| `MYSQL_DB` | MySQL database name | `database` |
| `AMQP_HOST` | RabbitMQ server hostname | `localhost` |
| `AMQP_PORT` | RabbitMQ server port | `5670` |
| `AMQP_VHOST` | RabbitMQ virtual host | `/` |
| `AMQP_USER` | RabbitMQ username | `guest` |
| `AMQP_PASSWORD` | RabbitMQ password | `guest` |
| `AMQP_SPEC_FILE` | AMQP specification file path | `/app/amqp0-9-1.xml` |

## Docker Compose Example

See `samples/docker-compose-sample.yml` for a complete example of running the service with all dependencies.

## Development

### Building Locally

```bash
# Build the image
./build-image.sh

# Run with local configuration
docker run -d \
  --name sms-cdr-consumer \
  --network host \
  jasmin-broker:latest
```

### Viewing Logs

```bash
docker logs -f sms-cdr-consumer
```

### Stopping the Container

```bash
docker stop sms-cdr-consumer
docker rm sms-cdr-consumer
```

## Components

### SMS CDR Consumer (`sms_cdr_consumer.py`)
The main application that:
- Connects to RabbitMQ to consume CDR messages
- Processes SMS delivery reports and billing information
- Stores data in MySQL
- Uses Redis for caching and state management

### Jasmin SMS Gateway
An open-source SMS gateway that handles:
- SMPP protocol connections
- SMS routing and delivery
- CDR generation

## Database Schema

### Required Configuration

Before running the consumer, you must:

1. **Activate `publish_submit_sm_resp` in Jasmin configuration** (`jasmin.cfg`)
2. **Create the `submit_log` table** in your MySQL database

### Table Schema

Run the following SQL to create the required table:

```sql
CREATE TABLE submit_log (
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
```

### Table Description

The `submit_log` table stores:
- **Message tracking**: `msgid`, `source_connector`, `routed_cid`
- **Addressing**: `source_addr`, `destination_addr`
- **Billing**: `rate`, `pdu_count`, `uid`
- **Content**: `short_message`, `binary_message`
- **Status tracking**: `status`, `trials`, `created_at`, `status_at`

The table includes optimized indexes for common query patterns on status, user ID, connector ID, and timestamps.

## Troubleshooting

### Connection Issues
- Verify all environment variables are correctly set
- Ensure network connectivity to Redis, MySQL, and RabbitMQ
- Check firewall rules and security groups

### Container Won't Start
- Check logs: `docker logs sms-cdr-consumer`
- Verify the image was built successfully
- Ensure all required environment variables are provided

### Message Processing Issues
- Verify RabbitMQ queue configuration
- Check AMQP credentials and permissions
- Review application logs for error messages
