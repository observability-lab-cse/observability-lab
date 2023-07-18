# Sample Java App

## Prerequisites

* CosmosDB account
* Docker

## Set up

Open the project in VS Code using dev containers [configuration file](../../.devcontainer/devcontainer.json).

Replace the properties values from [launchSettings.json](Properties/launchSettings.json) with the CosmosDB and EventHub properties:

```text
"EVENTHUBS_CONNECTION_STRING": "<>",
"STORAGE_CONNECTION_STRING": "<>",
"BLOB_CONTAINER_NAME": "<>",
"EVENTHUB_NAME": "<>",
"CONSUMER_GROUP": "devicemanager",
"DEVICE_API_URL":"http://localhost:8080"
```

## Run locally 

```bash
cd sample-application/device-manager/DeviceManager

dotnet run
```

## Run locally from docker
TBD
## Check results
