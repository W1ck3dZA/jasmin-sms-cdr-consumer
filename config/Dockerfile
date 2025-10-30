FROM python:3.9

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    default-libmysqlclient-dev \
    pkg-config \
    libmariadb-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install rabbitmqadmin and its dependencies
RUN curl -s https://raw.githubusercontent.com/rabbitmq/rabbitmq-server/v3.10.x/deps/rabbitmq_management/bin/rabbitmqadmin -o /usr/local/bin/rabbitmqadmin && \
    chmod +x /usr/local/bin/rabbitmqadmin && \
    pip install --no-cache-dir requests

# Install Python packages
RUN pip install --no-cache-dir \
    redis \
    twisted \
    txamqp \
    jasmin \
    smpp.twisted3 \
    && pip install --no-cache-dir mysqlclient

# Copy the script
COPY sms_cdr_consumer.py /app/sms_cdr_consumer.py

# Set working directory
WORKDIR /app

# Make the script executable
RUN chmod +x /app/sms_cdr_consumer.py

# Set environment variables with defaults
ENV REDIS_HOST=localhost \
    REDIS_PORT=6379 \
    MYSQL_HOST=localhost \
    MYSQL_PORT=3306 \
    MYSQL_USER=user \
    MYSQL_PASSWORD=password \
    MYSQL_DB=database \
    AMQP_HOST=localhost \
    AMQP_PORT=5670 \
    AMQP_VHOST=/ \
    AMQP_USER=guest \
    AMQP_PASSWORD=guest \
    AMQP_SPEC_FILE=/app/amqp0-9-1.xml

# Copy AMQP spec file
COPY config/amqp0-9-1.xml /app/

# Run the script
CMD ["python", "/app/sms_cdr_consumer.py"]
