# Start from Maven base image to build the app
FROM maven:3.8.5-openjdk-17 AS builder

WORKDIR /app

COPY . .

RUN mvn clean package -DskipTests

# Create minimal image for runtime
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
