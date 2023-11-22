@description('The name of the Log Analytics Workspace')
param workspaceName string

@description('Location for the Log Analytics Workspace')
param location string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
}

output id string = logAnalyticsWorkspace.id

param alertRuleName string = 'Avg processing time'

resource alertRuleAvgProcessingTime 'microsoft.insights/scheduledqueryrules@2023-03-15-preview' = {
  name: alertRuleName
  location: location
  properties: {
    displayName: alertRuleName
    severity: 2
    enabled: false
    evaluationFrequency: 'PT5M'
    scopes: [
      logAnalyticsWorkspace.id
    ]
    targetResourceTypes: [
      'microsoft.operationalinsights/workspaces'
    ]
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          query: ' AppTraces\n | where isnotempty(OperationId)\n | extend startTime = iif(Message startswith "Received event", TimeGenerated, datetime(null))\n | extend endTime = iif(AppRoleName == "devices-api", TimeGenerated, datetime(null))\n | partition hint.strategy=native by OperationId (\n   summarize startTime = take_any(startTime), endTime = take_any(endTime) by OperationId\n   )\n | where isnotempty(startTime) and isnotempty(endTime) \n | extend delta = (endTime - startTime) / 1s\n | project startTime, delta\n | summarize avg(delta) by bin(startTime,10m)\n | sort by startTime desc\n | take 1\n'
          timeAggregation: 'Average'
          metricMeasureColumn: 'avg_delta'
          dimensions: []
          operator: 'GreaterThan'
          threshold: '0.01'
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    autoMitigate: false
    actions: {
      customProperties: {}
      actionProperties: {}
    }
  }
}