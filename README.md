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

Connect to the Devices API (URL is specified in the output of the previous command, though it takes a couple of minutes until the API is fully operational), and create a couple of devices using the `POST` method.

Once devices are created, you can start the Devices Simulator, which will simulate generation of the temperature for each device.
To deploy it, execute:

```bash
make deploy-devices-simulator
```

## Step-by-step setup

* Create [infrastructure](./infrastructure/README.md) and connect to the AKS cluster.
* Build and push [devices-api](./sample-application/devices-api/README.md) image.
  Note: specify your project name (the same as for the infrastructure creation) with all lowercase letters.

  ```bash
  cd sample-application/devices-api
  docker build -t acr<project-name>.azurecr.io/devices-api:latest .
  az acr login --name acr<project-name>
  docker push acr<project-name>.azurecr.io/devices-api:latest
  ```

* Modify deployment file and specify your project name in the image.
* Deploy devices-api

  ```bash
  kubectl apply -f k8s-files/devices-api-deployment.yaml
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

* Modify the Azure Monitor instrumentation key (`INSTRUMENTATION_KEY_PLACEHOLDER`) in the [`collector.yaml`](./k8s-files/collector.yaml) file.
* Deploy the OpenTelemetry collector

    ```bash
    kubectl apply -f k8s-files/collector.yaml
    kubectl apply -f k8s-files/otel-collector-deployment.yaml
    ```

* To test the Devices API:
  * find the name of the pod:

    ```bash
    kubectl get pods -l app=devices-api
    ```

  * use it in the following command

    ```bash
    kubectl port-forward <pod-name> 8080:8080
    ```

  * Open your browser or use `curl http://localhost:8080/devices`. You should receive `[]`.
  * Navigate to `http://localhost:8080/` and create a couple of devices using the Devices API POST method.
* To simulate the temperature data for each of the created device, deploy the Devices Simulator
  * Replace `EVENT_HUB_CONNECTION_STRING_PLACEHOLDER` with your Event Hub connection string.
  * Replace `DEVICE_NAMES_PLACEHOLDER` with comma separated device names, that you previously created.
  * Deploy the simulator

    ```bash
    kubectl apply -f k8s-files/devices-simulator-deployment.yaml
    ```
