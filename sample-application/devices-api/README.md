# Sample Java App

## Run locally from Gradle

```bash
cd sample-application/devices-api

./gradlew bootRun
```

## Run locally from docker

Build project and run docker:

```bash
cd sample-application/devices-api

docker build -t devices-api .
docker run -p 8080:8080 devices-api .
```

## Check results

Go to http://localhost:8080/devices. The response should be `[]`