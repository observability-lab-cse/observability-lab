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
    echo ""
}

push_images(){
    echo "- PUSH module images to ACR"
    ACR_NAME=$(az acr list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    
    az acr login --name  "$ACR_NAME".azurecr.io 
    docker tag "$DEVICE_API_IMAGE_NAME" "$ACR_NAME".azurecr.io/"$DEVICE_API_IMAGE_NAME"
    docker push "$ACR_NAME".azurecr.io/"$DEVICE_API_IMAGE_NAME":"$TAG"
    docker tag "$DEVICE_MANAGER_IMAGE_NAME" "$ACR_NAME".azurecr.io/"$DEVICE_MANAGER_IMAGE_NAME"
    docker push "$ACR_NAME".azurecr.io/"$DEVICE_MANAGER_IMAGE_NAME":"$TAG" 
    echo ""
}


deploy(){
    echo "- DEPLOY module image"
    AKS_NAME=$(az aks list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    az aks get-credentials \
    --resource-group "$ENV_RESOURCE_GROUP_NAME" \
    --name "$AKS_NAME" \
    --overwrite-existing
    
    cat k8s-files/devices-api-deployment.yaml | sed -e "s/\${project-name}/$ENV_PROJECT_NAME/" | kubectl apply -f  -
    cat k8s-files/device-manager-deployment.yaml | sed -e "s/\${project-name}/$ENV_PROJECT_NAME/" | kubectl apply -f  -
    echo ""
}

deploy_otel_collector(){
    echo "- DEPLOY Open Telemetry Collector"
    AKS_NAME=$(az aks list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    az aks get-credentials \
    --resource-group "$ENV_RESOURCE_GROUP_NAME" \
    --name "$AKS_NAME" \
    --overwrite-existing

    APP_INSIGHTS_INSTRUMENTATION_KEY=$(az graph query -q "Resources | where type =~ 'microsoft.insights/components' and name =~ 'appi-$ENV_PROJECT_NAME' and resourceGroup =~ '$ENV_RESOURCE_GROUP_NAME' | project properties.InstrumentationKey" | jq -r '.data[0].properties_InstrumentationKey')
    cat k8s-files/collector.yaml | sed -e "s#INSTRUMENTATION_KEY_PLACEHOLDER#$APP_INSIGHTS_INSTRUMENTATION_KEY#" | kubectl apply -f  -
    kubectl apply -f k8s-files/otel-collector-deployment.yaml
    echo ""
}

deploy_devices_simulator(){
    echo "- DEPLOY Devices Simulator"
    AKS_NAME=$(az aks list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    az aks get-credentials \
    --resource-group "$ENV_RESOURCE_GROUP_NAME" \
    --name "$AKS_NAME" \
    --overwrite-existing

    EVENT_HUB_CONNECTION_STRING=$(az eventhubs eventhub authorization-rule keys list --resource-group "$ENV_RESOURCE_GROUP_NAME" --namespace-name evhns-"$ENV_PROJECT_NAME" --eventhub-name evh-"$ENV_PROJECT_NAME" --name Send  --query primaryConnectionString -o tsv)
    cat k8s-files/devices-simulator-deployment.yaml | sed -e "s#EVENT_HUB_CONNECTION_STRING_PLACEHOLDER#$EVENT_HUB_CONNECTION_STRING#" | kubectl apply -f  -
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
        elif [[ "$1" == "--deploy_otel_collector" ]]; then
        echo "--- Deploy to AKS Cluster  ---"
        deploy_otel_collector
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