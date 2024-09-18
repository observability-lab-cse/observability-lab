@description('Cosmos DB account name')
param accountName string

@description('Location for the Cosmos DB account.')
param location string

@description('The name for the SQL API database')
param databaseName string

@description('The name for the SQL API container')
param containerName string

@description('The name of managed identity to be used for role assignment')
param managedIdentityName string = 'myManagedIdentity'

resource account 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' = {
  name: accountName
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
      }
    ]
    disableLocalAuth: true
  }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-05-15' = {
  parent: account
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      throughput: 1000
    }
  }
}

resource cosmosDbRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-01-01' = {
  name: '${account.name}/myRoleAssignment'
  properties: {
    roleDefinitionId: '${account.id}/sqlRoleDefinitions/myRoleDefinition'
    principalId: managedIdentity.properties.principalId
    scope: account.id
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-05-15' = {
  parent: database
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/myPartitionKey'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/_etag/?'
          }
        ]
      }
    }
  }
}

output cosmosDBEndpoint string = account.properties.documentEndpoint
output cosmosDBAccountName string = account.name
output managedIdentityId string = managedIdentity.id
