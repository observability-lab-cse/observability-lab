FROM openjdk:17-slim

EXPOSE 8080

RUN mkdir /app
COPY . /app
WORKDIR /app

RUN ./gradlew build

ENTRYPOINT ["java","-jar","build/libs/devices-api.jar"]


