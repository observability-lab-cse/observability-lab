@description('Unique project name used to compose resource names. Valid characters include alphanumeric values only')
param projectName string

@description('The location where the resource is created.')
param location string = resourceGroup().location

module k8s './k8s.bicep' = {
  name: 'k8s_deployment'
  params: {
    location: location
    clusterName: 'aks-${projectName}'
    dnsPrefix: projectName
  }
}

module acr './acr.bicep' = {
  name: 'acr_deployment'
  params: {
    acrName: 'acr${projectName}'
    location: location
    kubeletIdentityId: k8s.outputs.kubeletIdentityId
  }
}

module logAnalyticsWorkspace './log_analytics.bicep' = {
  name: 'log_analytics_deployment'
  params: {
    workspaceName: 'log-${projectName}'
    location: location
  }
}

module appInsights './app_insights.bicep' = {
  name: 'app_insights_deployment'
  params: {
    appInsightsName: 'appi-${projectName}'
    location: location
    workspaceResourceId: logAnalyticsWorkspace.outputs.id
  }
  dependsOn:[
    logAnalyticsWorkspace
  ]
}

module cosmosDb './cosmos_db.bicep' = {
  name: 'cosmos_db_deployment'
  params: {
    accountName: 'cosmos-${toLower(projectName)}'
    databaseName: 'cosmos-db-${projectName}'
    containerName: 'devicesContainer'
    location: location
  }
}

module kv './keyvault.bicep' = {
  name: 'key_vault_deployment'
  params: {
    location: location
    kvName: 'kv-${projectName}'
    cosmosDBEndpoint: cosmosDb.outputs.cosmosDBEndpoint
    cosmosDBAccountName: cosmosDb.outputs.cosmosDBAccountName
    clusterKeyVaultSecretProviderObjectId: k8s.outputs.clusterKeyVaultSecretProviderObjectId
    clusterKeyVaultSecretProviderClientId: k8s.outputs.clusterKeyVaultSecretProviderClientId
    eventHubConnectionStringListen: eventHub.outputs.eventHubConnectionStringListen
    eventHubConnectionStringSend: eventHub.outputs.eventHubConnectionStringSend
    eventHubName: eventHub.outputs.eventHubName
    storageAccountConnectionString: eventHub.outputs.storageAccountConnectionString
    aksId: k8s.outputs.aksId
  }
}

module eventHub './event_hub.bicep' = {
  name: 'event_hub_deployment'
  params: {
    eventHubNamespaceName: 'evhns-${projectName}'
    eventHubName: 'evh-${projectName}'
    location: location
    storageAccountName: 'st${projectName}'
  }
}

output acrName string = acr.outputs.acrName
output clusterName string = k8s.outputs.clusterName
output aksKeyVaultSecretProviderClientId string = k8s.outputs.clusterKeyVaultSecretProviderClientId

