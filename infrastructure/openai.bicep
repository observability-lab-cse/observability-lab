@description('Unique project name used to compose resource names. Valid characters include alphanumeric values only')
param projectName string

@description('The location where the resource is created.')
param location string = 'eastus'

@allowed([
  'S0'
])
param sku string = 'S0'

resource openAi 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' = {
  name: 'openai-${projectName}'
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
    disableLocalAuth: false
  }
}

resource gpt3_5 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = {
  parent: openAi
  name: '${projectName}GPT35'
  sku: {
    name: 'Standard'
    capacity: 120
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-35-turbo'
      version: '0301'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    currentCapacity: 120
    raiPolicyName: 'Microsoft.Default'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: 'kv-${projectName}'
  
  resource openAIKey 'secrets' = {
    name: 'OpenAIKey'
    properties: {
      value: listKeys(resourceId('Microsoft.CognitiveServices/accounts', openAi.name), '2021-04-30').key1
    }
  }
  
  resource openAIEndpoint 'secrets' = {
    name: 'OpenAIEndpoint'
    properties: {
      value: 'https://${openAi.name}.openai.azure.com/openai/deployments/${gpt3_5.name}'
    }
  }
}


