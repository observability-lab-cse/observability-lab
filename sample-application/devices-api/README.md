# Sample Java App

## Prerequisites

* CosmosDB account
* Docker

## Set up

Open the project in VS Code using dev containers [configuration file](../../.devcontainer/devcontainer.json).

Replace the properties values from [application.properties](src/main/resources/application.properties) with the CosmosDB properties:

* azure.cosmosdb.uri - uri 
* azure.cosmosdb.key - primary key
* azure.cosmosdb.database - database name

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