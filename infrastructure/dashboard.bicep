@description('Location')
param location string = 'westeurope'

@description('Resource Id of the log analytics workspace which the data will be ingested to')
param eventHubResourceId string = '/subscriptions/8e5a6219-88a9-42f2-998e-46c08e340a60/resourceGroups/obs-lab-rg/providers/Microsoft.EventHub/namespaces/evhns-obslab'

param dashboardName string ='ahdsahjksd'
param dataExplorerName string = 'dxc-obslab'
param dxdbName string = 'dxc-obslab'

@description('The friendly name for the workbook that is used in the Gallery or Saved List.  This name must be unique within a resource group.')
param workbookDisplayName string
// = 'Data Visibility'

@description('The gallery that the workbook will been shown under. Supported values include workbook, tsg, etc. Usually, this is \'workbook\'')
param workbookType string = 'workbook'

@description('The id of resource instance to which the workbook will be associated')
param workbookSourceId string = '/subscriptions/8e5a6219-88a9-42f2-998e-46c08e340a60/resourceGroups/obs-lab-rg/providers/Microsoft.Insights/components/appi-obslab'

@description('The unique guid for this workbook instance')
param workbookId string = newGuid()

// var newstringss = replace('\'{"version":"Notebook/1.0","items":[{"type":3,"content":{"version":"KqlItem/1.0","query":"{\\"version\\":\\"AzureDataExplorerQuery/1.0\\",\\"queryText\\":\\"IngestionTestCosmos\\\\n| extend state_icon = case( Status has \\\\\\"IN_USE\\\\\\", \\\\\\"Available\\\\\\", Status has \\\\\\"NEW\\\\\\",\\\\\\"pending\\\\\\", Status has \\\\\\"ERROR\\\\\\",\\\\\\"error\\\\\\",\\\\\\"none\\\\\\")\\\\n| summarize arg_max(_timestamp,*) by Id\\",\\"clusterName\\":\\"dataExplorerNamePlh.westeurope\\",\\"databaseName\\":\\"dxdbNamePlh\\"}","size":2,"queryType":9,"visualization":"graph","graphSettings":{"type":2,"topContent":{"columnMatch":"Name","formatter":1},"centerContent":{"columnMatch":"Value","formatter":1,"numberFormat":{"unit":17,"options":{"style":"decimal","maximumFractionDigits":2,"maximumSignificantDigits":3}},"tooltipFormat":{"tooltip":"Temperature"}},"bottomContent":{"columnMatch":"state_icon","formatter":11,"numberFormat":{"unit":0,"options":{"style":"decimal"}}},"nodeIdField":"Name","sourceIdField":"Id","targetIdField":"Id","graphOrientation":3,"showOrientationToggles":false,"nodeSize":null,"staticNodeSize":100,"colorSettings":{"nodeColorField":"Value","type":4,"heatmapPalette":"blue","heatmapMin":null,"heatmapMax":null,"emptyValueColor":"gray"},"hivesMargin":5}},"name":"query - 2"}],"isLocked":false,"fallbackResourceIds":["/subscriptions/8e5a6219-88a9-42f2-998e-46c08e340a60/resourceGroups/obs-lab-rg/providers/Microsoft.Insights/components/appi-obslab"]}\', 'dataExplorerNamePlh', dataExplorerName)
var newstring = '{"version":"Notebook/1.0","items":[{"type":3,"content":{"version":"KqlItem/1.0","query":"{\\"version\\":\\"AzureDataExplorerQuery/1.0\\",\\"queryText\\":\\"IngestionTestCosmos\\\\n| extend state_icon = case( Status has \\\\\\"IN_USE\\\\\\", \\\\\\"Available\\\\\\", Status has \\\\\\"NEW\\\\\\",\\\\\\"pending\\\\\\", Status has \\\\\\"ERROR\\\\\\",\\\\\\"error\\\\\\",\\\\\\"none\\\\\\")\\\\n| summarize arg_max(_timestamp,*) by Id\\",\\"clusterName\\":\\"${dataExplorerName}.westeurope\\",\\"databaseName\\":\\"${dxdbName}\\"}","size":2,"queryType":9,"visualization":"graph","graphSettings":{"type":2,"topContent":{"columnMatch":"Name","formatter":1},"centerContent":{"columnMatch":"Value","formatter":1,"numberFormat":{"unit":17,"options":{"style":"decimal","maximumFractionDigits":2,"maximumSignificantDigits":3}},"tooltipFormat":{"tooltip":"Temperature"}},"bottomContent":{"columnMatch":"state_icon","formatter":11,"numberFormat":{"unit":0,"options":{"style":"decimal"}}},"nodeIdField":"Name","sourceIdField":"Id","targetIdField":"Id","graphOrientation":3,"showOrientationToggles":false,"nodeSize":null,"staticNodeSize":100,"colorSettings":{"nodeColorField":"Value","type":4,"heatmapPalette":"blue","heatmapMin":null,"heatmapMax":null,"emptyValueColor":"gray"},"hivesMargin":5}},"name":"query - 2"}],"isLocked":false,"fallbackResourceIds":["${workbookSourceId}"]}'
resource workbookId_resource 'microsoft.insights/workbooks@2022-04-01' = {
  name: workbookId
  location: location
  kind: 'shared'
  properties: {
    displayName: workbookDisplayName
    serializedData: newstring
    version: '1.0'
    sourceId: workbookSourceId
    category: workbookType
  }
  dependsOn: []
}

resource Observability 'Microsoft.Portal/dashboards@2015-08-01-preview' = {
  properties: {
    lenses: {
      '0': {
        order: 0
        parts: {
          '0': {
            position: {
              x: 0
              y: 0
              colSpan: 8
              rowSpan: 6
            }
            metadata: {
              inputs: [
                {
                  name: 'ComponentId'
                  value: workbookSourceId
                }
              ]
              type: 'Extension/AppInsightsExtension/PartType/AppMapGalPt'
              settings: {}
              asset: {
                idInputName: 'ComponentId'
                type: 'ApplicationInsights'
              }
            }
          }
          '1': {
            position: {
              x: 8
              y: 0
              colSpan: 7
              rowSpan: 4
            }
            metadata: {
              inputs: [
                {
                  name: 'ComponentId'
                  value: workbookSourceId
                  isOptional: true
                }
                {
                  name: 'TimeContext'
                  value: null
                  isOptional: true
                }
                {
                  name: 'ResourceIds'
                  value: [
                    workbookSourceId
                  ]
                  isOptional: true
                }
                {
                  name: 'ConfigurationId'
                  value: workbookId_resource.id
                  isOptional: true
                }
                {
                  name: 'Type'
                  value: 'workbook'
                  isOptional: true
                }
                {
                  name: 'GalleryResourceType'
                  value: 'microsoft.insights/components'
                  isOptional: true
                }
                {
                  name: 'PinName'
                  value: 'Data Visibility'
                  isOptional: true
                }
                {
                  name: 'StepSettings'
                  value: '{"version":"KqlItem/1.0","query":"{\\"version\\":\\"AzureDataExplorerQuery/1.0\\",\\"queryText\\":\\"IngestionTestCosmos\\\\n| extend state_icon = case( Status has \\\\\\"IN_USE\\\\\\", \\\\\\"Available\\\\\\", Status has \\\\\\"NEW\\\\\\",\\\\\\"pending\\\\\\", Status has \\\\\\"ERROR\\\\\\",\\\\\\"error\\\\\\",\\\\\\"none\\\\\\")\\\\n| summarize arg_max(_timestamp,*) by Id\\",\\"clusterName\\":\\"datavisibilityspike.westeurope\\",\\"databaseName\\":\\"basedb\\"}","size":2,"queryType":9,"visualization":"graph","graphSettings":{"type":2,"topContent":{"columnMatch":"Name","formatter":1},"centerContent":{"columnMatch":"Value","formatter":1,"numberFormat":{"unit":17,"options":{"style":"decimal","maximumFractionDigits":2,"maximumSignificantDigits":3}},"tooltipFormat":{"tooltip":"Temperature"}},"bottomContent":{"columnMatch":"state_icon","formatter":11,"numberFormat":{"unit":0,"options":{"style":"decimal"}}},"nodeIdField":"Name","sourceIdField":"Id","targetIdField":"Id","graphOrientation":3,"showOrientationToggles":false,"nodeSize":null,"staticNodeSize":100,"colorSettings":{"nodeColorField":"Value","type":4,"heatmapPalette":"blue","heatmapMin":null,"heatmapMax":null,"emptyValueColor":"gray"},"hivesMargin":5}}'
                  isOptional: true
                }
                {
                  name: 'ParameterValues'
                  value: {}
                  isOptional: true
                }
                {
                  name: 'Location'
                  value: 'eastus'
                  isOptional: true
                }
              ]
              type: 'Extension/AppInsightsExtension/PartType/PinnedNotebookQueryPart'
            }
          }
          '2': {
            position: {
              x: 15
              y: 0
              colSpan: 2
              rowSpan: 2
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/ClockPart'
              settings: {
                content: {
                  timezoneId: 'W. Europe Standard Time'
                  timeFormat: 'h:mma'
                  version: 1
                }
              }
            }
          }
          '3': {
            position: {
              x: 8
              y: 4
              colSpan: 7
              rowSpan: 2
            }
            metadata: {
              inputs: [
                {
                  name: 'resourceTypeMode'
                  isOptional: true
                }
                {
                  name: 'ComponentId'
                  isOptional: true
                }
                {
                  name: 'Scope'
                  value: {
                    resourceIds: [
                      workbookSourceId
                    ]
                  }
                  isOptional: true
                }
                {
                  name: 'PartId'
                  value: '46aafe0f-c0ea-452d-85bb-c018f72e93b9'
                  isOptional: true
                }
                {
                  name: 'Version'
                  value: '2.0'
                  isOptional: true
                }
                {
                  name: 'TimeRange'
                  value: 'P1D'
                  isOptional: true
                }
                {
                  name: 'DashboardId'
                  isOptional: true
                }
                {
                  name: 'DraftRequestParameters'
                  isOptional: true
                }
                {
                  name: 'Query'
                  value: 'traces \n'
                  isOptional: true
                }
                {
                  name: 'ControlType'
                  value: 'AnalyticsGrid'
                  isOptional: true
                }
                {
                  name: 'SpecificChart'
                  isOptional: true
                }
                {
                  name: 'PartTitle'
                  value: 'Analytics'
                  isOptional: true
                }
                {
                  name: 'PartSubTitle'
                  value: 'appi-obslab'
                  isOptional: true
                }
                {
                  name: 'Dimensions'
                  isOptional: true
                }
                {
                  name: 'LegendOptions'
                  isOptional: true
                }
                {
                  name: 'IsQueryContainTimeRange'
                  value: false
                  isOptional: true
                }
              ]
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
              settings: {
                content: {
                  Query: 'exceptions  \n\n'
                }
              }
              partHeader: {
                title: 'Error lines'
                subtitle: ''
              }
            }
          }
          '4': {
            position: {
              x: 0
              y: 6
              colSpan: 15
              rowSpan: 4
            }
            metadata: {
              inputs: [
                {
                  name: 'options'
                  isOptional: true
                }
                {
                  name: 'sharedTimeRange'
                  isOptional: true
                }
              ]
              type: 'Extension/HubsExtension/PartType/MonitorChartPart'
              settings: {
                content: {
                  options: {
                    chart: {
                      metrics: [
                        {
                          resourceMetadata: {
                            id: eventHubResourceId
                          }
                          name: 'IncomingRequests'
                          aggregationType: 1
                          namespace: 'microsoft.eventhub/namespaces'
                          metricVisualization: {
                            displayName: 'Incoming Requests'
                            resourceDisplayName: 'evhns-obslab'
                          }
                        }
                      ]
                      title: 'Sum Incoming Requests for evhns-obslab'
                      titleKind: 1
                      visualization: {
                        chartType: 2
                        legendVisualization: {
                          isVisible: true
                          position: 2
                          hideSubtitle: false
                        }
                        axisVisualization: {
                          x: {
                            isVisible: true
                            axisType: 2
                          }
                          y: {
                            isVisible: true
                            axisType: 1
                          }
                        }
                        disablePinning: true
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    metadata: {
      model: {
        timeRange: {
          value: {
            relative: {
              duration: 24
              timeUnit: 1
            }
          }
          type: 'MsPortalFx.Composition.Configuration.ValueTypes.TimeRange'
        }
        filterLocale: {
          value: 'en-us'
        }
        filters: {
          value: {
            MsPortalFx_TimeRange: {
              model: {
                format: 'utc'
                granularity: 'auto'
                relative: '24h'
              }
              displayCache: {
                name: 'UTC Time'
                value: 'Past 24 hours'
              }
              filteredPartIds: [
                'StartboardPart-UnboundPart-18a1dda2-d4b5-4d8c-aaf7-c479257e0532'
                'StartboardPart-LogsDashboardPart-27f034ec-60c8-4c54-ad32-f3cd520bd0c3'
                'StartboardPart-MonitorChartPart-18a1dda2-d4b5-4d8c-aaf7-c479257e0501'
                'StartboardPart-PinnedNotebookQueryPart-4a8f1713-6d24-4bf9-8b6e-ae021f305e31'
              ]
            }
          }
        }
      }
    }
  }
  name: dashboardName
  location: location
  tags: {
    'hidden-title': dashboardName
  }
}




output test string = newstring

