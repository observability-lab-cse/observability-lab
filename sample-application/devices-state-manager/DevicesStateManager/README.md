# Sample C# Devices State Manager Service

## Prerequisites

- CosmosDB account
- Docker
- EventHub

## Set up

Open the project in VS Code using dev containers [configuration file](../../.devcontainer/devcontainer.json).

Replace the values from [appsettings.json](appsettings.json) with the CosmosDB and EventHub properties:

```text
"EVENT_HUB_CONNECTION_STRING": "<>",
"STORAGE_CONNECTION_STRING": "<>",
"BLOB_CONTAINER_NAME": "<>",
"EVEN_THUB_NAME": "<>",
"CONSUMER_GROUP": "devicesstatemanager",
"DEVICE_API_URL":"http://localhost:8080"
```

> Note: When running the devices-api service locally you can keep the url domain to be `localhost`. However, as soon as you run the service in a container replace the domain with the service name.

## Run locally

```bash
cd sample-application/devices-state-manager/DevicesStateManager

dotnet run
```

## Run locally from docker

```bash
cd sample-application/devices-state-manager/DevicesStateManager

docker build -t devices-state-manager .
docker run devices-state-manager .
```

## Check results

When application starts running, you should see messages being received and processed

```text
info: DevicesStateManager.EventHubReceiverService[0]
Received event: {"deviceId": "device-42", "deviceTimestamp": "2023-07-17T17:41:52.8690130Z", "temp": 23.70572735914296}
```
