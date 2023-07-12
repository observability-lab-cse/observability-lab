@description('The name of the Event Hub Namespace')
param eventHubNamespaceName string

@description('The name of the Event Hub')
param eventHubName string

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

resource authorizationRule 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2022-01-01-preview' = {
  name: 'Send'
  parent: eventHub
  properties: {
    rights: [
      'Send'
    ]
  }
}

resource consumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-01-01-preview' = {
  name: 'DeviceManager'
  parent: eventHub
}
