FROM openjdk:17-slim

WORKDIR /app

COPY ./build/libs/devices-api.jar /app
EXPOSE 8181:8080


ENTRYPOINT ["java","-jar","devices-api.jar"]


