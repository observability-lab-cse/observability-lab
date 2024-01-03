#!/bin/bash
DEVICE_API_IMAGE_NAME="devices-api"
DEVICE_MANAGER_IMAGE_NAME="devices-state-manager"
TAG="latest"


# For project-name use only alphanumeric characters
build_images() {
    echo "- BUILD module images"
    cd ./sample-application/devices-api || { echo "Directory not found" && exit "2"; }
    echo "Image Tag: $DEVICE_API_IMAGE_NAME:$TAG"
    docker build -t "$DEVICE_API_IMAGE_NAME":"$TAG" .
    echo ""
    cd ../devices-state-manager/DevicesStateManager || { echo "Directory not found" && exit "2"; }
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

    cat k8s-files/devices-state-manager-deployment.yaml | \
    # cat k8s-files/devices-state-manager-deployment-with-otel-operator.yaml | \
    sed -e "s/\${project-name}/$ENV_PROJECT_NAME/" | \
    kubectl apply -f -

    DEVICES_API_IP=""
    while [ -z $DEVICES_API_IP ]; do
        DEVICES_API_IP=$(kubectl get service devices-api-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        echo "Waiting for Devices API to start..."
        sleep 1;
    done

    HEALTHCHECK_URL="http://$DEVICES_API_IP:8080/health"
    while [[ $(curl -s -o /dev/null -w "%{http_code}" $HEALTHCHECK_URL) != "200" ]]; do
        echo "Still a few seconds..."
        sleep 1;
    done

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


deploy_devices_data_simulator(){
    echo "- DEPLOY Devices Data Simulator"
    AKS_NAME=$(az aks list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    az aks get-credentials \
    --resource-group "$ENV_RESOURCE_GROUP_NAME" \
    --name "$AKS_NAME" \
    --overwrite-existing

    DEVICES_API_IP=$(kubectl get service devices-api-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    DEVICE_NAMES=$(curl -X GET --header 'Accept: application/json' "http://$DEVICES_API_IP:8080/devices" | jq -r '[.[].name] | join(",")')
    echo "Configuring the Devices Data Simulator for the following device names: $DEVICE_NAMES"

    cat k8s-files/devices-data-simulator-deployment.yaml | \
    sed -e "s#DEVICE_NAMES_PLACEHOLDER#$DEVICE_NAMES#" | \
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
        elif [[ "$1" == "--deploy_devices_data_simulator" ]]; then
        echo "--- Deploy to AKS Cluster  ---"
        deploy_devices_data_simulator
        exit 0
        
    else
        echo "Usage: $0 [--create | -c] | [--delete | -d]"
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main "$@"
fi