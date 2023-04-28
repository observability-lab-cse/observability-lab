# Sample application

## Overview

TBD

## How to run

```bash
cd sample-application

docker compose up --build

```

Currently, the docker-compose file starts the following components: 
* `devices-api` - a java service
* OpenTelemetry collector

After executing the command above go to http://localhost:8080/devices. The response should show an empty list.