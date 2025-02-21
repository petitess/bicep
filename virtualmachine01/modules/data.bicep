param prefix string
param location string
param workspaceName string
param workspaceResourceId string

var tags = resourceGroup().tags

resource dataEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2023-03-11' = {
  name: 'data-endpoint-${prefix}-01'
  location: location
  tags: tags
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

resource DataRuleVMInsights 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: 'data-vminsights-${prefix}-01'
  location: location
  properties: {
    description: 'Data collection rule for VM Insights.'
    dataSources: {
      performanceCounters: [
        {
          name: 'VMInsightsPerfCounters'
          streams: [
            'Microsoft-InsightsMetrics'
          ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            '\\VmInsights\\DetailedMetrics'
          ]
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
          workspaceResourceId: workspaceResourceId
          name: workspaceName
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-InsightsMetrics'
        ]
        destinations: [
          workspaceName
        ]
      }
      {
        streams: [
          'Microsoft-ServiceMap'
        ]
        destinations: [
          workspaceName
        ]
      }
    ]
  }
}

resource DataRuleWin 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
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
          workspaceResourceId: workspaceResourceId
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

resource DataRuleLinux 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: 'data-linux-${prefix}-01'
  location: location
  tags: tags
  kind: 'Linux'
  properties: {
    dataSources: {
      syslog: [
        {
          name: 'sysLogsDataSource01'
          facilityNames: [
            'cron'
            'daemon'
            'kern'
          ]
          streams: [
            'Microsoft-Syslog'
          ]
          logLevels: [
            'Alert'
            'Critical'
            'Emergency'
          ]
        }
        {
          name: 'sysLogsDataSource02'
          facilityNames: [
            'syslog'
          ]
          streams: [
            'Microsoft-Syslog'
          ]
          logLevels: [
            'Alert'
            'Critical'
            'Emergency'
            'Error'
            'Warning'
          ]
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceResourceId
          name: workspaceName
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Syslog'
        ]
        destinations: [
          workspaceName
        ]
        transformKql: 'source'
        outputStream: 'Microsoft-Syslog'
      }
    ]
  }
}

output DataWinId string = DataRuleWin.id
output DataLinuxId string = DataRuleLinux.id
output DataVMInsightsId string = DataRuleVMInsights.id
output dataEndpointId string = dataEndpoint.id
