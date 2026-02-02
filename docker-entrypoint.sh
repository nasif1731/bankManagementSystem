#!/bin/sh
set -e

# Wait for MySQL to be ready - just sleep since docker-compose has health checks
echo "Waiting for MySQL server to be ready..."
sleep 15

echo "MySQL should be ready now"

# Initialize database if needed
if [ -f "ATM_Simulator.sql" ]; then
  echo "Initializing database..."
  mysql -h ${DB_HOST} -u ${DB_USER} -p${DB_PASSWORD} < ATM_Simulator.sql 2>/dev/null || echo "Database already initialized"
fi

echo "Starting application..."
# Execute the main command
exec "$@"
