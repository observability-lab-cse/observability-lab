@description('Unique project name used to compose resource names. Valid characters include alphanumeric values only')
param projectName string

@description('The location where the resource is created.')
param location string = resourceGroup().location


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

//A add outputs and put int kv
