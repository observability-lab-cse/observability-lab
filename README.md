# observability-lab

## Quick setup

The `Makefile` automates infrastructure creation and applications deployment within a couple of commands.
To use it create a `.env` in the root of the project and add the following content to it.

```text
ENV_RESOURCE_GROUP_NAME=<rg-name>
ENV_LOCATION="westeurope"
ENV_PROJECT_NAME=<project-name> # should just be lowercase letters or numbers
```

To provision infrastructure, deploy applications and the Open Telemetry Collector to the cluster, run the following commands:

```bash
az login
az account set --subscription <name or ID of your subscription>
make
```

Connect to the Device API (URL is specified in the output of the previous command, though it takes a couple of minutes until the API is fully operational), and create a couple of devices using the `POST` method.

Once devices are created, you can start the Device Simulator, which will simulate generation of the temperature for each device.
To deploy it, execute:

```bash
make deploy-device-simulator
```

Then, call the Device API using `GET /devices` method, and you should see your devices with `IN_USE` status, and a response similar to this:

```json
[
  {
    "id":"cc831450-4ec9-45ec-a72a-ce4f96e2d477",
    "name":"device-1",
    "value":25.14771,
    "status":"IN_USE"
  },
  {
    "id":"1a569548-11e8-4245-bde8-e3774ff1aa42",
    "name":"device-2",
    "value":26.55738,
    "status":"IN_USE"
  }
]
```

## Step-by-step setup

* Create [infrastructure](./infrastructure/README.md) and connect to the AKS cluster.
* Build and push [device-api](./sample-application/device-api/README.md) image.
  Note: specify your project name (the same as for the infrastructure creation) with all lowercase letters.

  ```bash
  cd sample-application/device-api
  docker build -t acr<project-name>.azurecr.io/device-api:latest .
  az acr login --name acr<project-name>
  docker push acr<project-name>.azurecr.io/device-api:latest
  ```

* Modify deployment file and specify your project name in the image.
* Deploy device-api

  ```bash
  kubectl apply -f k8s-files/device-api-deployment.yaml
  ```

* Build and push `device-manager` image.

  ```bash
  cd sample-application/device-manager/DeviceManager
  docker build -t acr<project-name>.azurecr.io/device-manager:latest .
  docker push acr<project-name>.azurecr.io/device-manager:latest
  ```

* Modify the [deployment file](./k8s-files/device-manager-deployment.yaml) and specify your project name in the image.
* Deploy device-manager

  ```bash
  kubectl apply -f k8s-files/device-manager-deployment.yaml
  ```

* Modify the Azure Monitor instrumentation key (`INSTRUMENTATION_KEY_PLACEHOLDER`) in the [`collector-config.yaml`](./k8s-files/collector-config.yaml) file.
* Deploy the OpenTelemetry collector

    ```bash
    kubectl apply -f k8s-files/collector-config.yaml
    kubectl apply -f k8s-files/otel-collector-deployment.yaml
    ```

* To test the Device API:
  * find the name of the pod:

    ```bash
    kubectl get pods -l app=device-api
    ```

  * use it in the following command

    ```bash
    kubectl port-forward <pod-name> 8080:8080
    ```

  * Open your browser or use `curl http://localhost:8080/devices`. You should receive `[]`.
  * Navigate to `http://localhost:8080/` and create a couple of devices using the Device API POST method.
* To simulate the temperature data for each of the created device, deploy the Device Simulator
  * Replace `EVENT_HUB_CONNECTION_STRING_PLACEHOLDER` with your Event Hub connection string.
  * Replace `DEVICE_NAMES_PLACEHOLDER` with comma separated device names, that you previously created.
  * Deploy the simulator

    ```bash
    kubectl apply -f k8s-files/device-simulator-deployment.yaml
    ```
