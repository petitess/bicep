var location = resourceGroup().location

resource log 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'log-01'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource dcr_vminsight 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: 'data-windows-01'
  location: location
  kind: 'Windows'
  properties: {
    dataSources: {
      performanceCounters: [
        {
          streams: [
            'Microsoft-InsightsMetrics'
          ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            '\\VmInsights\\DetailedMetrics'
          ]
          name: 'VMInsightsPerfCounters'
        }
      ]
      windowsEventLogs: [
        {
          streams: [
            'Microsoft-Event'
          ]
          xPathQueries: [
            'Application!*[System[(Level=1 or Level=2 or Level=3)]]'
            'System!*[System[(Level=1 or Level=2 or Level=3)]]'
            'Application!*[System[(EventID=666)]]'
          ]
          name: 'eventLogsDataSource'
        }
      ]
      extensions: [
        {
          streams: [
            'Microsoft-ServiceMap'
          ]
          extensionName: 'DependencyAgent'
          extensionSettings: {}
          name: 'DependencyAgentDataSource'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: log.id
          name: 'log-infra-01'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          'log-infra-01'
        ]
        transformKql: 'source'
        outputStream: 'Microsoft-Event'
      }
      {
        streams: [
          'Microsoft-InsightsMetrics'
        ]
        destinations: [
          'log-infra-01'
        ]
      }
      {
        streams: [
          'Microsoft-ServiceMap'
        ]
        destinations: [
          'log-infra-01'
        ]
      }
    ]
  }
}
