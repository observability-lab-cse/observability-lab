# Sample Java App

Execute the below commands from [sample-application/devices-api](./) folder.

## Run locally from Gradle

```bash
./gradlew bootRun
```

## Run locally from docker

Build project and run docker:

```bash
docker build -t devices-api .
docker run -p 8080:8080 devices-api .
```

## Check results

Go to http://localhost:8080/devices. The response should be `[]`