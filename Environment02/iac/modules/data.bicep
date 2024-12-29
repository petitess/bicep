targetScope = 'resourceGroup'

param env string
param location string
param workspaceResourceId string

var tags = resourceGroup().tags

resource dataEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2023-03-11' = {
  name: 'data-endpoint-${env}-01'
  location: location
  tags: tags
  properties: {
    
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

resource DataRuleWin 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: 'data-windows-${env}-01'
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
          name: 'log-01'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          'log-01'
        ]
        transformKql: 'source'
        outputStream: 'Microsoft-Event'
      }
    ]
  }
}

resource DataRuleLinux 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: 'data-linux-${env}-01'
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
          name: 'log-01'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Syslog'
        ]
        destinations: [
          'log-01'
        ]
        transformKql: 'source'
        outputStream: 'Microsoft-Syslog'
      }
    ]
  }
}

output DataRuleWinId string = DataRuleWin.id
output DataRuleLinuxId string = DataRuleLinux.id
output dataEndpointId string = dataEndpoint.id
