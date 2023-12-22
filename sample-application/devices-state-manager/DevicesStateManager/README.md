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
"DEVICE_API_URL":"http://localhost:8080",
"OTEL_DOTNET_AUTO_METRICS_ADDITIONAL_SOURCES": "DevicesStateManager"
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

If you run the whole solution, including the Devices Simulator, then when Devices State Manager starts running, you should see messages being received and processed

```text
info: DevicesStateManager.EventHubReceiverService[0]
Received event: {"deviceId": "device-42", "deviceTimestamp": "2023-07-17T17:41:52.8690130Z", "temp": 23.70572735914296}
```

## Health check

Devices State Manager has health-check implemented as a tcp probe so that kubernetes can use it in the readiness probe. If you want to check health-check locally you can execute following steps:

1. Run the Devices State Manager locally
2. In the application logs you should see a log indicating that the tcp probe service started:

```
info: DevicesStateManager.TcpHealthProbeService[0]
Started health check service.
```

3. Request tcp connection on port 8090, you can use e.g. nc command from terminal:

```bash
nc localhost 8090
```

4. Now in your application logs you should see a message:

```
Successfully processed health check request.
```
