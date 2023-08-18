targetScope = 'resourceGroup'

param env string
param location string
param workspaceName string

var tags = resourceGroup().tags

resource CollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
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
          workspaceResourceId: resourceId('Microsoft.OperationalInsights/workspaces', workspaceName)
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

resource CollectionRuleLinux 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
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
          workspaceResourceId: resourceId('Microsoft.OperationalInsights/workspaces', workspaceName)
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


output DataWinId string = CollectionRule.id
output DataLinuxId string = CollectionRuleLinux.id
