FROM openjdk:17-slim

EXPOSE 8080

RUN mkdir /app
COPY . /app
WORKDIR /app
RUN ./gradlew build

COPY build/libs/devices-api.jar /app

ENTRYPOINT ["java","-jar","devices-api.jar"]


