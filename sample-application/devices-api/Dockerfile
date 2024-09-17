FROM eclipse-temurin:17 AS builder

RUN mkdir /app
COPY . /app
WORKDIR /app

RUN ./gradlew build

FROM eclipse-temurin:17
WORKDIR /app
COPY --from=builder /app/build/libs/devices-api.jar /app

# Download opentelemetry-javaagent.jar
RUN curl -L -O https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.31.0/opentelemetry-javaagent.jar

ENTRYPOINT ["java", "-javaagent:opentelemetry-javaagent.jar", "-jar","devices-api.jar"]
