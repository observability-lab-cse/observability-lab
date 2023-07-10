#!/bin/bash
IMAGE_NAME="devices-api"
TAG="latest"


# For project-name use only alphanumeric characters
build_image() {
    echo "- BUILD module images"
    cd ./sample-application/devices-api || { echo "Directory not found" && exit "2"; }
    echo "Image Tag: $IMAGE_NAME:$TAG"
    docker build -t "$IMAGE_NAME":"$TAG" .
    echo ""
}

push_image(){
    echo "- PUSH module images to ACR"
    ACR_NAME=$(az acr list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    
    az acr login --name  "$ACR_NAME".azurecr.io 
    docker tag "$IMAGE_NAME" "$ACR_NAME".azurecr.io/"$IMAGE_NAME"
    docker push "$ACR_NAME".azurecr.io/"$IMAGE_NAME":"$TAG" 
    echo ""
}

run_container(){
    echo "- RUN module image"
    ACR_NAME=$(az acr list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    
    az acr login --name  "$ACR_NAME".azurecr.io 
    docker run "$ACR_NAME".azurecr.io/"$IMAGE_NAME":"$TAG"
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
        echo "--- Build and Push Image ---"
        build_image
        push_image
        exit 0
        
        elif [[ "$1" == "--run" ]] || [[ "$1" == "-r" ]]; then
        echo "--- Build and Run Image  ---"
        build_image
        run_container
        exit 0
        elif [[ "$1" == "--deploy" ]] || [[ "$1" == "-d" ]]; then
        echo "--- Deploy to AKS Cluster  ---"
        deploy
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