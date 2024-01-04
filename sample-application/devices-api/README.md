# Sample Java App

## Prerequisites

* CosmosDB account
* Docker

## Setup

Open the project in VS Code using dev containers [configuration file](../../.devcontainer/devcontainer.json).

Replace the properties values from [application.properties](src/main/resources/application.properties) with the CosmosDB properties:

* azure.cosmosdb.uri - Cosmos DB instance URI
* azure.cosmosdb.key - Cosmos DB instance primary key
* azure.cosmosdb.database - name of the database created in the Cosmos DB instance

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

You should get redirected to the swagger if you go to the root url `http://localhost:8080/` 

> Note: In case of redirect issues the swagger url is the following `http://localhost:8080/swagger-ui.html`

or

Go to http://localhost:8080/devices. The response should be `[]`

## Telemetry

The application is [automatically instrumented](https://opentelemetry.io/docs/instrumentation/java/getting-started/#instrumentation) using open-telemetry java-agent jar that is being downloaded as part of Dockerfile instructions.

The open-telemetry java-agent supports automatic telemetry orchestration of number of libraries, frameworks, and application servers. [Full list of supported libraries](https://github.com/open-telemetry/opentelemetry-java-instrumentation/blob/main/docs/supported-libraries.md).