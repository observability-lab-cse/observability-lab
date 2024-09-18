#!/bin/bash
DEVICE_ASSISTANT_IMAGE_NAME="device-assistant"
DEVICE_API_IMAGE_NAME="devices-api"
DEVICE_MANAGER_IMAGE_NAME="devices-state-manager"
TAG="latest"
TARGET_PLATFORM=linux/amd64


# For project-name use only alphanumeric characters
build_images() {
    echo "- BUILD module images"

    pushd "./sample-application/device-assistant" > /dev/null || { echo "Directory not found" && exit "2"; }
    echo "Image: ${DEVICE_ASSISTANT_IMAGE_NAME}:${TAG}"
    docker build -t "${DEVICE_ASSISTANT_IMAGE_NAME}:${TAG}" --platform "$TARGET_PLATFORM" .
    echo ""
    popd > /dev/null

    pushd "./sample-application/devices-api" > /dev/null || { echo "Directory not found" && exit "2"; }
    echo "Image: ${DEVICE_API_IMAGE_NAME}:${TAG}"
    docker build -t "${DEVICE_API_IMAGE_NAME}:${TAG}" --platform "$TARGET_PLATFORM" .
    echo ""
    popd > /dev/null

    pushd "./sample-application/devices-state-manager/DevicesStateManager" > /dev/null || { echo "Directory not found" && exit "2"; }
    echo "Image: ${DEVICE_MANAGER_IMAGE_NAME}:${TAG}"
    docker build -t "${DEVICE_MANAGER_IMAGE_NAME}:${TAG}" --platform "$TARGET_PLATFORM" .
    echo ""

    echo "Image: ${DEVICE_MANAGER_IMAGE_NAME}:no-auto-instrumentation"
    docker build -f Dockerfile.no-auto-instrumentation -t "${DEVICE_MANAGER_IMAGE_NAME}:no-auto-instrumentation" --platform "$TARGET_PLATFORM" .
    echo ""
    popd > /dev/null
}


# For project-name use only alphanumeric characters
build_images_acr() {
    echo "- BUILD module images"
    ACR_NAME=$(az acr list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)

    pushd "./sample-application/device-assistant" > /dev/null || { echo "Directory not found" && exit "2"; }
    echo "Image: ${DEVICE_ASSISTANT_IMAGE_NAME}:${TAG}"
    az acr build --registry "$ACR_NAME" --image  "${DEVICE_ASSISTANT_IMAGE_NAME}:${TAG}" .
    echo ""
    popd > /dev/null

    pushd "./sample-application/devices-api" > /dev/null || { echo "Directory not found" && exit "2"; }
    echo "Image: ${DEVICE_API_IMAGE_NAME}:${TAG}"
    docker build -t "${DEVICE_API_IMAGE_NAME}:${TAG}" --platform "$TARGET_PLATFORM" .
    echo ""
    popd > /dev/null

    pushd "./sample-application/devices-state-manager/DevicesStateManager" > /dev/null || { echo "Directory not found" && exit "2"; }
    echo "Image: ${DEVICE_MANAGER_IMAGE_NAME}:${TAG}"
    az acr build --registry "$ACR_NAME" --image  "${DEVICE_MANAGER_IMAGE_NAME}:${TAG}" .
    echo ""

    echo "Image: ${DEVICE_MANAGER_IMAGE_NAME}:no-auto-instrumentation"
    az acr build --registry $ACR_NAME --image "${DEVICE_MANAGER_IMAGE_NAME}:no-auto-instrumentation" --file "Dockerfile.no-auto-instrumentation"
    echo ""
    popd > /dev/null
}

push_images() {
    echo "- PUSH module images to ACR"
    ACR_NAME=$(az acr list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)

    az acr login --name  "$ACR_NAME".azurecr.io

    for image in "$DEVICE_ASSISTANT_IMAGE_NAME" "$DEVICE_API_IMAGE_NAME" "$DEVICE_MANAGER_IMAGE_NAME";do
        echo "Image: ${image}:${TAG}"
        docker tag "${image}:${TAG}" "${ACR_NAME}.azurecr.io/${image}:${TAG}"
        docker push "${ACR_NAME}.azurecr.io/${image}:${TAG}"
    done

    docker tag "$DEVICE_MANAGER_IMAGE_NAME":"$TAG" "$ACR_NAME".azurecr.io/"$DEVICE_MANAGER_IMAGE_NAME":"$TAG"
    docker push "$ACR_NAME".azurecr.io/"$DEVICE_MANAGER_IMAGE_NAME":"$TAG"

    docker tag "${DEVICE_MANAGER_IMAGE_NAME}:no-auto-instrumentation" "${ACR_NAME}.azurecr.io/${DEVICE_MANAGER_IMAGE_NAME}:no-auto-instrumentation"
    docker push "${ACR_NAME}.azurecr.io/${DEVICE_MANAGER_IMAGE_NAME}:no-auto-instrumentation"

    echo ""
}


deploy_device_services() {
    echo "- DEPLOY modules: API and Devices Manager"
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

deploy_secret_store() {
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

deploy_ai() {
    echo "- DEPLOY secret store provider (with AI)"
    AKS_NAME=$(az aks list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    az aks get-credentials \
    --resource-group "$ENV_RESOURCE_GROUP_NAME" \
    --name "$AKS_NAME" \
    --overwrite-existing

    CLUSTER_CLIENT_ID=$(az deployment group show -g "$ENV_RESOURCE_GROUP_NAME" -n k8s_deployment --query properties.outputs.clusterKeyVaultSecretProviderClientId.value -o tsv)
    KEY_VAULT_TENANT_ID=$(az deployment group show -g "$ENV_RESOURCE_GROUP_NAME" -n key_vault_deployment --query properties.outputs.kvTenantId.value -o tsv)
    cat k8s-files/secret-store-ai.yaml | \
    sed -e "s/\${project-name}/$ENV_PROJECT_NAME/" \
        -e "s/\${clusterKeyVaultSecretProviderClientId}/$CLUSTER_CLIENT_ID/" \
        -e "s/\${keyVaultTenantId}/$KEY_VAULT_TENANT_ID/" | \
    kubectl apply -f  -

    cat k8s-files/device-assistant-deployment.yaml | \
    sed -e "s/\${project-name}/$ENV_PROJECT_NAME/" | \
    kubectl apply -f  -
}

deploy_otel_collector() {
    echo "- DEPLOY Open Telemetry Collector"
    AKS_NAME=$(az aks list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    az aks get-credentials \
    --resource-group "$ENV_RESOURCE_GROUP_NAME" \
    --name "$AKS_NAME" \
    --overwrite-existing

    az extension add --name resource-graph
    APP_INSIGHTS_INSTRUMENTATION_KEY=$(az graph query -q "Resources | where type =~ 'microsoft.insights/components' and name =~ 'appi-$ENV_PROJECT_NAME' and resourceGroup =~ '$ENV_RESOURCE_GROUP_NAME' | project properties.InstrumentationKey" | jq -r '.data[0].properties_InstrumentationKey')
    cat k8s-files/collector-config.yaml | sed -e "s#INSTRUMENTATION_KEY_PLACEHOLDER#$APP_INSIGHTS_INSTRUMENTATION_KEY#" | kubectl apply -f  -
    kubectl apply -f k8s-files/otel-collector-deployment.yaml
    echo ""
}

deploy_opentelemetry_operator_with_collector() {
    echo "- DEPLOY Open Telemetry Operator with Collector"
    AKS_NAME=$(az aks list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    az aks get-credentials \
    --resource-group "$ENV_RESOURCE_GROUP_NAME" \
    --name "$AKS_NAME" \
    --overwrite-existing

    APP_INSIGHTS_INSTRUMENTATION_KEY=$(az graph query -q "Resources | where type =~ 'microsoft.insights/components' and name =~ 'appi-$ENV_PROJECT_NAME' and resourceGroup =~ '$ENV_RESOURCE_GROUP_NAME' | project properties.InstrumentationKey" | jq -r '.data[0].properties_InstrumentationKey')
    echo "Deploying cert-manager"
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml
    echo "Deploying Open Telemetry Operator"
    kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/download/v0.87.0/opentelemetry-operator.yaml
    while true; do
        my_list=$(kubectl get endpoints opentelemetry-operator-webhook-service -n opentelemetry-operator-system -o jsonpath='{.subsets[*].addresses[*].ip}')
        if [ -n "$my_list" ]; then
            echo "The OpenTelemetry Operator webhook service is ready!"
            break
        else
            echo "Waiting for the OpenTelemetry Operator webhook service to be ready..."
            sleep 5
        fi
    done

    echo "Deploying Open Telemetry Collector"
    cat k8s-files/collector-for-otel-operator.yaml | sed -e "s#INSTRUMENTATION_KEY_PLACEHOLDER#$APP_INSIGHTS_INSTRUMENTATION_KEY#" | kubectl apply -f  -
    echo "Deploying Instrumentation resource to enable auto-instrumentation"
    kubectl apply -f k8s-files/otel-instrumentation.yaml
    echo ""
}

deploy_devices_data_simulator() {
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
        elif [[ "$1" == "--acr_build_push" ]]; then
        echo "--- Build and Push Images ---"
        build_images_acr
        push_images
        exit 0
        elif [[ "$1" == "--deploy" ]] || [[ "$1" == "-d" ]]; then
        echo "--- Deploy to AKS Cluster ---"
        deploy_device_services
        exit 0
        elif [[ "$1" == "--deploy_secret_store" ]]; then
        echo "--- Deploy to AKS Cluster ---"
        deploy_secret_store
        exit 0
        elif [[ "$1" == "--deploy_ai" ]]; then
        echo "--- Deploy AI components to AKS Cluster ---"
        deploy_ai
        exit 0
        elif [[ "$1" == "--deploy_otel_collector" ]]; then
        echo "--- Deploy to AKS Cluster ---"
        deploy_otel_collector
        exit 0
        elif [[ "$1" == "--deploy_opentelemetry_operator_with_collector" ]]; then
        echo "--- Deploy to AKS Cluster ---"
        deploy_opentelemetry_operator_with_collector
        exit 0
        elif [[ "$1" == "--deploy_devices_data_simulator" ]]; then
        echo "--- Deploy to AKS Cluster ---"
        deploy_devices_data_simulator
        exit 0

    else
        echo "Usage: $0 [--push | -p] | [--acr_build_push] | [--deploy | -d] | [--deploy_secret_store] | [--deploy_ai] | [--deploy_otel_collector] | [--deploy_opentelemetry_operator_with_collector] | [--deploy_devices_data_simulator]"
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main "$@"
fi