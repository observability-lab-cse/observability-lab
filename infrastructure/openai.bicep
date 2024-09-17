@description('Azure Open AI name (<name>-<resourceGroupName>)')
param aiServiceName string

@description('Location for all resources.')
param location string

@allowed([
  'S0'
])
param sku string = 'S0'

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: aiServiceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: sku
  }
  kind: 'OpenAI'
  properties: {
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Deny'
    }
    disableLocalAuth: true
  }
}
