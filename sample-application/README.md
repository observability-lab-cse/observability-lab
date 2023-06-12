# Sample application

## Overview

This project contains a sample device API that creates and retrieves devices from a [Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/introduction). Both the device API, as well as Cosmos DB, exposes telemetry data, to either be sent to [Log Analytics Workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview) or exporter by a telemetry agent like [OTEL-Collector](https://opentelemetry.io/docs/collector/).

![image](./path-1-architecture.jpg)

## How to run

Create `.env` file and set `EVENT_HUB_CONNECTION_STRING` with Event Hub connection string.

```bash
cd sample-application

docker compose up --build
```

Currently, the docker-compose file starts the following components:
* `devices-api` - a java service
* `SensorDataGenerator` - .NET console application
* OpenTelemetry collector
* [Azure Device Telemetry Simulator](https://learn.microsoft.com/en-us/samples/azure-samples/iot-telemetry-simulator/azure-iot-device-telemetry-simulator/)

After executing the command above go to http://localhost:8080/devices. The response should show an empty list.
