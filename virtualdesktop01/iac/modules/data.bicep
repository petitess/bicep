param prefix string
param location string
param workspaceName string
param workspaceId string

var tags = resourceGroup().tags

resource DataRuleWin 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'data-win-${prefix}-01'
  location: location
  tags: tags
  kind: 'Windows'
  properties: {
    dataSources: {
      windowsEventLogs: [
        {
          name: 'eventLogsDataSource'
          streams: [
            'Microsoft-Event'
          ]
          xPathQueries: [
            'Application!*[System[(Level=1 or Level=2 or Level=3)]]'
            'System!*[System[(Level=1 or Level=2 or Level=3)]]'
          ]
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceId
          name: workspaceName
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          workspaceName
        ]
        transformKql: 'source'
        outputStream: 'Microsoft-Event'
      }
    ]
  }
}

output DataWinId string = DataRuleWin.id
