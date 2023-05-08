# Sample application

## Overview

TBD

## How to run

```bash
cd sample-application

docker compose up --build

```

The docker-compose file starts the following services:

- Java service - devices-api
- .NET console application - dotnet-module 


After executing the command above go to http://localhost:8080/devices. The response should show an empty list.