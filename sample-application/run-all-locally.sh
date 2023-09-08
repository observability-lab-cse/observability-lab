#!/bin/bash

source ../.env

DEVICE_NAME_TO_CREATE=device-42

echo "COSMOS_DB_URI=$(az cosmosdb show --name cosmos-$ENV_PROJECT_NAME --resource-group $ENV_RESOURCE_GROUP_NAME --query documentEndpoint)" >> ./.env
echo "COSMOS_DB_KEY=$(az cosmosdb keys list --name cosmos-$ENV_PROJECT_NAME --resource-group $ENV_RESOURCE_GROUP_NAME --type keys --query primaryMasterKey)" >> ./.env
echo "COSMOS_DB_NAME=cosmos-db-$ENV_PROJECT_NAME" >> ./.env
echo "EVENT_HUB_LISTEN_POLICY_CONNECTION_STRING=$(az eventhubs eventhub authorization-rule keys list --resource-group "$ENV_RESOURCE_GROUP_NAME" --namespace-name evhns-"$ENV_PROJECT_NAME" --eventhub-name evh-"$ENV_PROJECT_NAME" --name Listen  --query primaryConnectionString -o tsv)" >> ./.env
echo "STORAGE_CONNECTION_STRING=$(az storage account show-connection-string --name st$ENV_PROJECT_NAME --resource-group $ENV_RESOURCE_GROUP_NAME -o tsv)" >> ./.env
echo "EVENT_HUB_NAME=evh-$ENV_PROJECT_NAME" >> ./.env
echo "BLOB_CONTAINER_NAME=event-hub-data" >> ./.env
echo "EVENT_HUB_SEND_POLICY_CONNECTION_STRING=$(az eventhubs eventhub authorization-rule keys list --resource-group "$ENV_RESOURCE_GROUP_NAME" --namespace-name evhns-"$ENV_PROJECT_NAME" --eventhub-name evh-"$ENV_PROJECT_NAME" --name Send  --query primaryConnectionString -o tsv)" >> ./.env
echo "DEVICE_NAMES=$DEVICE_NAME_TO_CREATE" >> ./.env

az extension add --name resource-graph
APP_INSIGHTS_INSTRUMENTATION_KEY=$(az graph query -q "Resources | where type =~ 'microsoft.insights/components' and name =~ 'appi-$ENV_PROJECT_NAME' and resourceGroup =~ '$ENV_RESOURCE_GROUP_NAME' | project properties.InstrumentationKey" | jq -r '.data[0].properties_InstrumentationKey')
sed -i "s/INSTRUMENTATION_KEY_PLACEHOLDER/$APP_INSIGHTS_INSTRUMENTATION_KEY/g" ./otel-collector/otelcol-config.yml

docker compose down
docker compose up --build -d

while true; do
    response=$(curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d "$DEVICE_NAME_TO_CREATE" 'http://localhost:8080/devices' -w '%{http_code}' -o /dev/null)
    retry_interval=5

    if [[ "$response" == "201" ]]; then
        echo "A new device $DEVICE_NAME_TO_CREATE successfully created"
        break
    else
        echo "Devices API is not ready yet. Retrying in $retry_interval seconds..."
        sleep $retry_interval
    fi
done
