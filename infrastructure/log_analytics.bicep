@description('The name of the Log Analytics Workspace')
param workspaceName string

@description('Location for the Log Analytics Workspace')
param location string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
}

output id string = logAnalyticsWorkspace.id
