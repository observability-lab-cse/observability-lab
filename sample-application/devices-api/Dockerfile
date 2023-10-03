FROM eclipse-temurin:17

RUN mkdir /app
COPY . /app
WORKDIR /app

# Download opentelemetry-javaagent.jar
RUN curl -L -O https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar

RUN ./gradlew build

ENTRYPOINT ["java", "-javaagent:opentelemetry-javaagent.jar", "-jar","build/libs/devices-api.jar"]


