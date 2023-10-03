# Sample C# Devices Manager Service

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
"CONSUMER_GROUP": "DevicesManager",
"DEVICE_API_URL":"http://localhost:8080"
```

> Note: When running the devices-api service locally you can keep the url domain to be `localhost`. However, as soon as you run the service in a container replace the domain with the service name.

## Run locally

```bash
cd sample-application/devices-manager/DevicesManager

dotnet run
```

## Run locally from docker

```bash
cd sample-application/devices-manager/DevicesManager

docker build -t devices-manager .
docker run devices-manager .
```

## Check results

When application starts running, you should see messages being received and processed

```text
info: DevicesManager.EventHubReceiverService[0]
Received event: {"deviceId": "device-42", "deviceTimestamp": "2023-07-17T17:41:52.8690130Z", "temp": 23.70572735914296}
```
