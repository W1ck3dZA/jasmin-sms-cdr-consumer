# Jasmin SMS CDR Consumer

A lightweight Docker container for consuming and logging SMS Call Detail Records (CDR) from Jasmin SMS Gateway to MySQL with Redis caching.

## Quick Start

```bash
docker run -d \
  --name sms-cdr-consumer \
  -e REDIS_HOST=your-redis-host \
  -e MYSQL_HOST=your-mysql-host \
  -e MYSQL_USER=your-user \
  -e MYSQL_PASSWORD=your-password \
  -e MYSQL_DB=your-database \
  -e AMQP_HOST=your-rabbitmq-host \
  yourusername/jasmin-sms-cdr-consumer:latest
```

## What This Image Does

This container:
- ✅ Consumes SMS CDR messages from RabbitMQ queues
- ✅ Processes delivery reports and billing information
- ✅ Stores SMS logs in MySQL with full message tracking
- ✅ Uses Redis for caching and state management
- ✅ Supports multipart SMS messages
- ✅ Tracks message status updates via DLRs

## Prerequisites

### 1. Jasmin Configuration
Enable CDR publishing in your Jasmin SMS Gateway (`jasmin.cfg`):
```ini
publish_submit_sm_resp = True
```

### 2. Database Setup
Create the required MySQL table:

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

## Usage Examples

### With Docker Compose

```yaml
version: '3.8'

services:
  sms-cdr-consumer:
    image: yourusername/jasmin-sms-cdr-consumer:latest
    container_name: sms-cdr-consumer
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - MYSQL_HOST=mysql
      - MYSQL_PORT=3306
      - MYSQL_USER=jasmin
      - MYSQL_PASSWORD=secure_password
      - MYSQL_DB=jasmin_db
      - AMQP_HOST=rabbitmq
      - AMQP_PORT=5672
      - AMQP_VHOST=/
      - AMQP_USER=guest
      - AMQP_PASSWORD=guest
    depends_on:
      - redis
      - mysql
      - rabbitmq
    restart: unless-stopped

  redis:
    image: redis:alpine
    
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: jasmin_db
      MYSQL_USER: jasmin
      MYSQL_PASSWORD: secure_password
    
  rabbitmq:
    image: rabbitmq:3-management
    environment:
      RABBITMQ_DEFAULT_USER: guest
      RABBITMQ_DEFAULT_PASS: guest
```

### Standalone with External Services

```bash
docker run -d \
  --name sms-cdr-consumer \
  --restart unless-stopped \
  -e REDIS_HOST=10.0.1.10 \
  -e REDIS_PORT=6379 \
  -e MYSQL_HOST=10.0.1.20 \
  -e MYSQL_PORT=3306 \
  -e MYSQL_USER=jasmin_user \
  -e MYSQL_PASSWORD=your_secure_password \
  -e MYSQL_DB=jasmin_production \
  -e AMQP_HOST=10.0.1.30 \
  -e AMQP_PORT=5672 \
  -e AMQP_VHOST=jasmin \
  -e AMQP_USER=jasmin \
  -e AMQP_PASSWORD=amqp_password \
  yourusername/jasmin-sms-cdr-consumer:latest
```

## Monitoring

### View Logs
```bash
docker logs -f sms-cdr-consumer
```

### Check Container Status
```bash
docker ps | grep sms-cdr-consumer
```

### Restart Container
```bash
docker restart sms-cdr-consumer
```

## What Gets Logged

The consumer tracks:
- **Message Details**: Message ID, source/destination addresses, content
- **Billing Information**: Rate, PDU count, user ID
- **Routing**: Source connector, routed connector ID
- **Status Tracking**: Delivery status, timestamps, retry attempts
- **Multipart Support**: Automatic handling of concatenated SMS

## Troubleshooting

**Container exits immediately:**
- Check logs: `docker logs sms-cdr-consumer`
- Verify all required environment variables are set
- Ensure database table exists

**No messages being logged:**
- Verify `publish_submit_sm_resp` is enabled in Jasmin
- Check RabbitMQ connection and credentials
- Verify queue bindings in RabbitMQ management console

**Database connection errors:**
- Verify MySQL host, port, and credentials
- Ensure database and table exist
- Check network connectivity between containers

## Source Code & Documentation

- **GitHub Repository**: https://github.com/W1ck3dZA/jasmin-sms-cdr-consumer
- **Jasmin Documentation**: https://docs.jasminsms.com/en/latest/
- **Issues & Support**: quinten.rowland@gmail.com

---

**Built for Jasmin SMS Gateway** | Supports SMPP, HTTP, and SMPP Server connectors
