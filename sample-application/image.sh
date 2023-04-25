IMAGE_NAME="module1"
TAG="latest"


# For project-name use only alphanumeric characters
build_image() {
    echo "- Build module images"
    cd ./sample-application/devices-api
    docker build -t "$IMAGE_NAME":"$TAG" .
    echo ""
}

push_image(){
    echo "- Push module images to ACR"
    ACR_NAME=$(az acr list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    TOKEN=$(az acr login --name "$ACR_NAME"  --expose-token --output tsv --query accessToken)
    
    docker login "$ACR_NAME".azurecr.io --username 00000000-0000-0000-0000-000000000000 --password-stdin <<< $TOKEN
    docker push "$ACR_NAME".azurecr.io/"$IMAGE_NAME":"$TAG"
    echo ""
}

run_container(){
    echo "- RUN module image"
    ACR_NAME=$(az acr list -g "$ENV_RESOURCE_GROUP_NAME" --query "[0].name" -o tsv)
    TOKEN=$(az acr login --name "$ACR_NAME"  --expose-token --output tsv --query accessToken)
    
    docker login "$ACR_NAME".azurecr.io --username 00000000-0000-0000-0000-000000000000 --password-stdin <<< $TOKEN
    docker run "$ACR_NAME".azurecr.io/"$IMAGE_NAME":"$TAG"
}

run_main() {
    
    # .env included in root of repo
    # shellcheck disable=SC1091
    source .env
    
    if [[ "$1" == "--push" ]] || [[ "$1" == "-c" ]]; then
        echo "--- Creating infrastructure ---"
        build_image
        push_image
        exit 0
        
        elif [[ "$1" == "--run" ]] || [[ "$1" == "-d" ]]; then
        echo "--- Deleting infrastructure ---"
        build_image
        run_container
        exit 0
        
    else
        echo "Usage: $0 [--create | -c] | [--delete | -d]"
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main "$@"
fi