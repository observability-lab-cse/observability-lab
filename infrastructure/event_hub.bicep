@description('The name of the Event Hub Namespace')
param eventHubNamespaceName string

@description('The name of the Event Hub')
param eventHubName string

@description('The name of the Storage Account needed for storing Event Hub ownership and checkpointing data')
param storageAccountName string

@description('Location for the Event Hub Namespace')
param location string

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2022-01-01-preview' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
  parent: eventHubNamespace
  name: eventHubName
  properties: {
    messageRetentionInDays: 7
    partitionCount: 1
  }
}

resource sendAuthorizationRule 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2022-01-01-preview' = {
  name: 'Send'
  parent: eventHub
  properties: {
    rights: [
      'Send'
    ]
  }
}

resource listenAuthorizationRule 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2022-01-01-preview' = {
  name: 'Listen'
  parent: eventHub
  properties: {
    rights: [
      'Listen'
    ]
  }
}

resource consumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-01-01-preview' = {
  name: 'DevicesStateManager'
  parent: eventHub
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: 'event-hub-data'
  parent: blobService
}


var storageAccountKeys = storageAccount.listKeys().keys

output storageAccountConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccountKeys[0].value};EndpointSuffix=${environment().suffixes.storage}'
output eventHubConnectionString string = listenAuthorizationRule.listKeys().primaryConnectionString
output eventHubName string = eventHubName
