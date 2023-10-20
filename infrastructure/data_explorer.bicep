@description('Location for all resources')
param location string 

@description('Name of the cluster')
param clusterName string

@description('Name of the database')
param kustoDatabaseName string 

@description('Name of Cosmos DB account')
param cosmosDbAccountName string 

@description('Name of Cosmos DB database')
param cosmosDbDatabaseName string 

@description('Name of Cosmos DB container')
param cosmosDbContainerName string 

@description('Name of the sku')
param skuName string = 'Standard_D12_v2'

@description('# of nodes')
@minValue(2)
@maxValue(1000)
param skuCapacity int = 2

var cosmosDataReader = '00000000-0000-0000-0000-000000000001' 


resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = {
  name: cosmosDbAccountName
}

resource cosmosDbAccountName_Microsoft_Kusto_clusters_clusterName_cosmosDbAccountName_data_plane 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2022-08-15' = {
  parent: cosmosDbAccount
  name: guid(cluster.id, cosmosDbAccountName, 'data-plane')
  properties: {
    principalId: cluster.identity.principalId
    roleDefinitionId: resourceId('Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions', cosmosDbAccountName, cosmosDataReader)
    scope: cosmosDbAccount.id
  }
}

resource clusterName_kustoDatabaseName_db_script 'Microsoft.Kusto/clusters/databases/scripts@2022-11-11' = {
  parent: clusterName_kustoDatabase
  name: 'db-script'
  properties: {
    scriptContent: loadTextContent('script.kql')
    continueOnErrors: false
  }
}

resource clusterName_kustoDatabaseName_cosmosDbConnection 'Microsoft.Kusto/clusters/databases/dataConnections@2022-11-11' = {
  parent: clusterName_kustoDatabase
  name: 'cosmosDbConnection'
  location: location
  kind: 'CosmosDb'
  properties: {
    tableName: 'DeviceTemperature'
    mappingRuleName: 'DeviceMapping'
    managedIdentityResourceId: cluster.id
    cosmosDbAccountResourceId: cosmosDbAccount.id
    cosmosDbDatabase: cosmosDbDatabaseName
    cosmosDbContainer: cosmosDbContainerName
  }
  dependsOn: [
    cosmosDbAccountName_Microsoft_Kusto_clusters_clusterName_cosmosDbAccountName_data_plane

    clusterName_kustoDatabaseName_db_script
  ]
}

resource clusterName_kustoDatabase 'Microsoft.Kusto/clusters/databases@2022-11-11' = {
  parent: cluster
  name: kustoDatabaseName
  location: location
  kind: 'ReadWrite'
}



resource Microsoft_Kusto_clusters_clusterName_cosmosDbAccountName_rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: cosmosDbAccount
  name: guid(cluster.id, cosmosDbAccountName, 'rbac')
  properties: {
    description: 'Giving RBAC reader on Cosmos DB'
    principalId: cluster.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'fbdf93bf-df7d-467e-a4d2-9458aa1360c8')
  }
}

resource cluster 'Microsoft.Kusto/clusters@2022-11-11' = {
  name: clusterName
  location: location
  sku: {
    name: skuName
    tier: 'Standard'
    capacity: skuCapacity
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output name string = cluster.name
