# observability-lab

* Create [infrastructure](./infrastructure/README.md) and connect to the AKS cluster.
* Build and push [devices-api](./sample-application/devices-api/README.md) image.
  Note: specify your project name (the same as for the infrastructure creation) with all lowercase letters.

    ```bash
    cd sample-application/devices-api
    docker build -t acr<project-name>.azurecr.io/devices-api:v1 .
    az acr login --name acr<project-name>
    docker push acr<project-name>.azurecr.io/devices-api:v1
    ```

* Modify deployment file and specify your project name in the image.
* Deploy devices-api

    ```bash
    kubectl apply -f k8s-files/devices-api-deployment.yaml
    ```

* To test the devices-api:
  * find the name of the pod:

    ```bash
    `kubectl get pods -l app=devices-api`
    ```

  * use it in the following command

    ```bash
    kubectl port-forward <pod-name> 8080:8080
    ```

  * Open your browser or use `curl http://localhost:8080/devices`. You should receive `[]`.
