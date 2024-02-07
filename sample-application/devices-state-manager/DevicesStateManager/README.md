# Sample C# Devices State Manager Service

## Prerequisites

- CosmosDB account
- Docker
- EventHub

## Setup

Open the project in VS Code using dev containers [configuration file](../../.devcontainer/devcontainer.json).

Replace the values from [appsettings.json](appsettings.json) with the CosmosDB and EventHub properties:

```text
"EVENT_HUB_CONNECTION_STRING": "<>",                                    # Listen access policy connection string of the Event Hub created in your Event Hubs namespace
"STORAGE_CONNECTION_STRING": "<>",                                      # Connection string of the Storage account, needed to persist checkpoints of the Event Processor
"BLOB_CONTAINER_NAME": "<>",                                            # Name of the blob container created in your Storage account
"EVENT_HUB_NAME": "<>",                                                 # Name of the Event Hub created in your Event Hubs namespace
"CONSUMER_GROUP": "devicesstatemanager",                                # Name of the Event Hub consumer group
"DEVICE_API_URL":"http://localhost:8080",                               # Base URL of the Devices API service
"OTEL_DOTNET_AUTO_METRICS_ADDITIONAL_SOURCES": "DevicesStateManager"    # Name of the `Meter` defined to collect custom metrics emitted from the application
"OTEL_DOTNET_AUTO_TRACES_ADDITIONAL_SOURCES": "DeviceUpdate"            # Name of the created Activity Source
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

If you run the whole solution, including the Devices Simulator, then, once Devices State Manager starts running, you should see messages being received and processed:

```text
info: DevicesStateManager.EventHubReceiverService[0]
Received event: {"deviceId": "device-42", "deviceTimestamp": "2023-07-17T17:41:52.8690130Z", "temp": 23.70572735914296}
```

## Health check

Devices State Manager has a health-check implemented as a TCP probe, so that Kubernetes can use it in the readiness probe. If you want to check the health-check locally, you can execute following steps:

1. Run the Devices State Manager locally
2. In the application logs you should see a message indicating that the TCP probe service started:

```
info: DevicesStateManager.TcpHealthProbeService[0]
Started health check service.
```

3. Request a TCP connection on port 8090, for example using the `nc` command from your terminal:

```bash
nc localhost 8090
```

4. Now, in your application logs you should see the following message:

```
Successfully processed health check request.
```
