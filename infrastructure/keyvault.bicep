@description('Location obtained from resource group')
param location string = resourceGroup().location

@description('KeyVault name')
@minLength(1)
param kvName string

@description('Expected KeyVault sku')
@allowed([
  'premium'
  'standard'
])
param kvSku string = 'standard'

@description('Tenant Id for the service principal that will be in charge of KeyVault access')
@minLength(1)
param kvTenantId string = tenant().tenantId

//secrets stored in KeyVault

@description('Cosmos DB endpoint')
@minLength(1)
param cosmosDBEndpoint string

@description('Cosmos DB account name')
@minLength(1)
param cosmosDBAccountName string

@description('The Object ID of the user-defined Managed Identity used by the AKS Secret Provider')
@minLength(1)
@secure()
param clusterKeyVaultSecretProviderObjectId string

@description('The Client ID of the user-defined Managed Identity used by the AKS Secret Provider')
@minLength(1)
@secure()
param clusterKeyVaultSecretProviderClientId string

@description('ID of the AKS resource')
param aksId string

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: kvName
  location: location
  properties: {
    tenantId: kvTenantId
    sku: {
      family: 'A'
      name: kvSku
    }
    createMode: 'default'
    publicNetworkAccess: 'Enabled'
    accessPolicies: [
          {
            objectId: clusterKeyVaultSecretProviderObjectId
            permissions: {
              secrets: [
                'get'
              ]
            }
            tenantId: subscription().tenantId
          }
        ]
    enabledForTemplateDeployment: true
  }

  resource cosmosDBEndpointSecret 'secrets' = {
    name: 'CosmosDBEndpoint'
    properties: {
      value: cosmosDBEndpoint
    }
  }

  resource cosmosDBKeySecret 'secrets' = {
    name: 'CosmosDBKey'
    properties: {
      value: listKeys(resourceId('Microsoft.DocumentDB/databaseAccounts', cosmosDBAccountName), '2022-05-15').primaryMasterKey
    }
  }

  resource cosmosDBNameSecret 'secrets' = {
      name: 'CosmosDBName'
      properties: {
        value: cosmosDBAccountName
      }
    }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(aksId, keyVault.id, '00482a5a-887f-4fb3-b363-3b7fe8e74483') // ID of Key Vault Administrator role
  scope: keyVault
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
    principalId: clusterKeyVaultSecretProviderClientId
    principalType: 'User'
  }
}

output kvName string = keyVault.name
output kvId string = keyVault.id
output kvUrl string = keyVault.properties.vaultUri
output kvTenantId string = keyVault.properties.tenantId
