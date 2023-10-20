#!/bin/bash
# For project-name use only alphanumeric characters
create_resource_group() {
    echo "- Create resource group $ENV_RESOURCE_GROUP_NAME"
    az group create \
    --location "$ENV_LOCATION" \
    --name "$ENV_RESOURCE_GROUP_NAME"
    
    echo ""
}
create_infrastructure(){
    echo "- Create all needed resources in resource group $ENV_RESOURCE_GROUP_NAME"
    az deployment group create \
    --resource-group "$ENV_RESOURCE_GROUP_NAME" \
    --template-file ./infrastructure/main.bicep \
    --parameters projectName="$ENV_PROJECT_NAME"

    echo ""
}
connect_cluster(){
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

run_main() {
    
    # .env included in root of repo
    # shellcheck disable=SC1091
    source .env
    
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
        
    else
        echo "Usage: $0 [--create | -c] | [--delete | -d]"
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main "$@"
fi