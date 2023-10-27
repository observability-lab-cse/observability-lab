#!/bin/bash
DEVICE_API_IMAGE_NAME="devices-api"
DEVICE_MANAGER_IMAGE_NAME="device-manager"
TAG="latest"


# For project-name use only alphanumeric characters
build_images() {
    echo "- BUILD module images"
    cd ./sample-application/devices-api || { echo "Directory not found" && exit "2"; }
    echo "Image Tag: $DEVICE_API_IMAGE_NAME:$TAG"
    docker build -t "$DEVICE_API_IMAGE_NAME":"$TAG" .
    echo ""
    cd ../device-manager/DeviceManager || { echo "Directory not found" && exit "2"; }
    echo "Image Tag: $DEVICE_MANAGER_IMAGE_NAME:$TAG"
    docker build -t "$DEVICE_MANAGER_IMAGE_NAME":"$TAG" .
    echo "Image Tag: $DEVICE_MANAGER_IMAGE_NAME:no-auto-instrumentation"
    docker build -f Dockerfile.no-auto-instrumentation -t "$DEVICE_MANAGER_IMAGE_NAME":no-auto-instrumentation .
    echo ""
}

push_images(){
    echo "- PUSH module images to ACR"
    ACR_NAME=$(az acr list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    
    az acr login --name  "$ACR_NAME".azurecr.io 
    docker tag "$DEVICE_API_IMAGE_NAME" "$ACR_NAME".azurecr.io/"$DEVICE_API_IMAGE_NAME"
    docker push "$ACR_NAME".azurecr.io/"$DEVICE_API_IMAGE_NAME":"$TAG"
    docker tag "$DEVICE_MANAGER_IMAGE_NAME":"$TAG" "$ACR_NAME".azurecr.io/"$DEVICE_MANAGER_IMAGE_NAME":"$TAG"
    docker push "$ACR_NAME".azurecr.io/"$DEVICE_MANAGER_IMAGE_NAME":"$TAG"
    docker tag "$DEVICE_MANAGER_IMAGE_NAME":no-auto-instrumentation "$ACR_NAME".azurecr.io/"$DEVICE_MANAGER_IMAGE_NAME":no-auto-instrumentation
    docker push "$ACR_NAME".azurecr.io/"$DEVICE_MANAGER_IMAGE_NAME":no-auto-instrumentation
    echo ""
}


deploy(){

    echo "- DEPLOY modules: Devices API and Devices Manager"
    AKS_NAME=$(az aks list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    az aks get-credentials \
    --resource-group "$ENV_RESOURCE_GROUP_NAME" \
    --name "$AKS_NAME" \
    --overwrite-existing

    cat k8s-files/devices-api-deployment.yaml | \
    sed -e "s/\${project-name}/$ENV_PROJECT_NAME/" | \
    kubectl apply -f  -

    EVENT_HUB_CONNECTION_STRING=$(az eventhubs eventhub authorization-rule keys list --resource-group "$ENV_RESOURCE_GROUP_NAME" --namespace-name evhns-"$ENV_PROJECT_NAME" --eventhub-name evh-"$ENV_PROJECT_NAME" --name Listen  --query primaryConnectionString -o tsv)
    STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --name st$ENV_PROJECT_NAME --resource-group $ENV_RESOURCE_GROUP_NAME -o tsv)
    
    cat k8s-files/device-manager-deployment.yaml | \
    # cat k8s-files/device-manager-deployment-with-otel-operator.yaml | \
    sed -e "s/\${project-name}/$ENV_PROJECT_NAME/" \
        -e "s#EVENT_HUB_LISTEN_POLICY_CONNECTION_STRING_PLACEHOLDER#$EVENT_HUB_CONNECTION_STRING#" \
        -e "s#STORAGE_CONNECTION_STRING_PLACEHOLDER#$STORAGE_CONNECTION_STRING#" \
        -e "s#EVENT_HUB_NAME_PLACEHOLDER#evh-$ENV_PROJECT_NAME#" | \
    kubectl apply -f -

    DEVICES_API_IP=$(kubectl get service devices-api-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo "Devices API URL http://$DEVICES_API_IP:8080"
}

deploy_secret_store(){

    echo "- DEPLOY secret store provider"
    AKS_NAME=$(az aks list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    az aks get-credentials \
    --resource-group "$ENV_RESOURCE_GROUP_NAME" \
    --name "$AKS_NAME" \
    --overwrite-existing

    CLUSTER_CLIENT_ID=$(az deployment group show -g "$ENV_RESOURCE_GROUP_NAME" -n k8s_deployment --query properties.outputs.clusterKeyVaultSecretProviderClientId.value -o tsv)
    KEY_VAULT_TENANT_ID=$(az deployment group show -g "$ENV_RESOURCE_GROUP_NAME" -n key_vault_deployment --query properties.outputs.kvTenantId.value -o tsv)
    cat k8s-files/secret-store.yaml | \
    sed -e "s/\${project-name}/$ENV_PROJECT_NAME/" \
        -e "s/\${clusterKeyVaultSecretProviderClientId}/$CLUSTER_CLIENT_ID/" \
        -e "s/\${keyVaultTenantId}/$KEY_VAULT_TENANT_ID/" | \
    kubectl apply -f  -
}


deploy_devices_simulator(){
    echo "- DEPLOY Devices Simulator"
    AKS_NAME=$(az aks list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    az aks get-credentials \
    --resource-group "$ENV_RESOURCE_GROUP_NAME" \
    --name "$AKS_NAME" \
    --overwrite-existing

    DEVICES_API_IP=$(kubectl get service devices-api-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    DEVICE_NAMES=$(curl -X GET --header 'Accept: application/json' "http://$DEVICES_API_IP:8080/devices" | jq -r '[.[].name] | join(",")')
    echo "Configuring the devices simulator for the following device names: $DEVICE_NAMES"

    EVENT_HUB_CONNECTION_STRING=$(az eventhubs eventhub authorization-rule keys list --resource-group "$ENV_RESOURCE_GROUP_NAME" --namespace-name evhns-"$ENV_PROJECT_NAME" --eventhub-name evh-"$ENV_PROJECT_NAME" --name Send  --query primaryConnectionString -o tsv)
    cat k8s-files/devices-simulator-deployment.yaml | \
    sed -e "s#EVENT_HUB_CONNECTION_STRING_PLACEHOLDER#$EVENT_HUB_CONNECTION_STRING#" \
        -e "s#DEVICE_NAMES_PLACEHOLDER#$DEVICE_NAMES#" | \
    kubectl apply -f  -
    echo ""
}

run_main() {
    
    # .env included in root of repo
    # shellcheck disable=SC1091
    source .env
    
    if [[ "$1" == "--push" ]] || [[ "$1" == "-p" ]]; then
        echo "--- Build and Push Images ---"
        build_images
        push_images
        exit 0
        elif [[ "$1" == "--deploy" ]] || [[ "$1" == "-d" ]]; then
        echo "--- Deploy to AKS Cluster  ---"
        deploy
        exit 0
        elif [[ "$1" == "--deploy_secret_store" ]]; then
        echo "--- Deploy to AKS Cluster  ---"
        deploy_secret_store
        exit 0
        elif [[ "$1" == "--deploy_devices_simulator" ]]; then
        echo "--- Deploy to AKS Cluster  ---"
        deploy_devices_simulator
        exit 0
        
    else
        echo "Usage: $0 [--create | -c] | [--delete | -d]"
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main "$@"
fi