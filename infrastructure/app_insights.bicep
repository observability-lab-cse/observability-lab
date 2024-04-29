@description('The name of the Application Insights')
param appInsightsName string

@description('Location for the Application Insights')
param location string

@description('Resource Id of the log analytics workspace which the data will be ingested to')
param workspaceResourceId string

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'other'
  properties: {
    Application_Type: 'other'
    Request_Source: 'rest'
    WorkspaceResourceId: workspaceResourceId
  }
}
