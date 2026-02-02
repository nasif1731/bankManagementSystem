# Multi-stage build for ATM Simulator
FROM maven:3.9-eclipse-temurin-11 AS builder

WORKDIR /build

# Copy pom.xml and source files
COPY pom.xml .
COPY src/ ./src/

# Build with Maven
RUN mvn clean package -DskipTests -q

# Runtime stage
FROM eclipse-temurin:11-jre-alpine

WORKDIR /app

# Install MySQL client for database setup
RUN apk add --no-cache mysql-client

# Create non-root user
RUN addgroup -S appuser && adduser -S appuser -G appuser

# Copy compiled JAR from builder
COPY --from=builder /build/target/ATM_Simulator.jar .

# Copy database initialization script
COPY sql/ATM_Simulator.sql .

# Copy startup script
COPY docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh

# Change ownership
RUN chown -R appuser:appuser /app

USER appuser

# Expose port for database connection
EXPOSE 3306

# Set environment variables
ENV DB_HOST=mysql
ENV DB_USER=root
ENV DB_PASSWORD=root
ENV DB_NAME=bank_management_system

# Run the application
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["java", "-jar", "ATM_Simulator.jar"]
