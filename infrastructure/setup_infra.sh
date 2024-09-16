#!/bin/bash

# For project-name use only alphanumeric characters
create_resource_group() {
    echo "- Create resource group $ENV_RESOURCE_GROUP_NAME"
    az group create \
    --location "$ENV_LOCATION" \
    --name "$ENV_RESOURCE_GROUP_NAME"

    echo ""
}
create_infrastructure() {
    echo "- Create all needed resources in resource group $ENV_RESOURCE_GROUP_NAME"
    az deployment group create \
    --resource-group "$ENV_RESOURCE_GROUP_NAME" \
    --template-file ./infrastructure/main.bicep \
    --parameters projectName="$ENV_PROJECT_NAME"

    echo ""
}


create_observability_infrastructure() {
    echo "- Create all observability related resources in resource group $ENV_RESOURCE_GROUP_NAME"
    az deployment group create \
    --resource-group "$ENV_RESOURCE_GROUP_NAME" \
    --template-file ./infrastructure/main-obs.bicep \
    --parameters projectName="$ENV_PROJECT_NAME"

    echo ""
}

connect_cluster() {
    AKS_NAME=$(az aks list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    echo "- Connect to cluster $AKS_NAME"

    echo "- Add $AKS_NAME context to local .kubeconfig"
    az aks get-credentials \
    --resource-group "$ENV_RESOURCE_GROUP_NAME" \
    --name "$AKS_NAME" \
    --overwrite-existing
    echo ""
}

delete_infrastructure(){
    AKS_NAME=$(az aks list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    echo "- Delete resource group $ENV_RESOURCE_GROUP_NAME"
    az group delete \
    --name "$ENV_RESOURCE_GROUP_NAME" \
    --yes

    echo "- Delete AKS context"
    kubectl config delete-context "$AKS_NAME"
    echo ""
}

load_env_file() {
    ENV_FILE="${1:-.env}"

    # remove Windows line endings
    sed -i -e "s/\r//" "${ENV_FILE}"

    # export all variavles in the env file
    set -o allexport
    # shellcheck disable=SC1090,SC1091
    source "${ENV_FILE}"
    set +o allexport
}

run_main() {
    # load .env included in root of repo
    load_env_file

    if [[ "$1" == "--create" ]] || [[ "$1" == "-c" ]]; then
        echo "--- Creating infrastructure ---"
        create_resource_group
        create_infrastructure
        connect_cluster
        exit 0

    elif [[ "$1" == "--delete" ]] || [[ "$1" == "-d" ]]; then
        echo "--- Deleting infrastructure ---"
        delete_infrastructure
        exit 0

    elif [[ "$1" == "--create-obs" ]] || [[ "$1" == "-d" ]]; then
        echo "--- Creating observability infrastructure ---"
        create_observability_infrastructure
        exit 0
    else
        echo "Usage: $0 [--create | -c] | [--delete | -d]"
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main "$@"
fi