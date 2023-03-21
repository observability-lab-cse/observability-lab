FROM eclipse-temurin:17

RUN mkdir /app
COPY . /app
WORKDIR /app
RUN ./gradlew build

ENTRYPOINT ["java","-jar","build/libs/devices-api.jar"]


