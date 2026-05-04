param name string
param location string
param tags object = resourceGroup().tags

var solutions = contains(name, 'prod')
  ? [
      // 'VMInsights'
      // 'Security'
      // 'ServiceMap'
      'ChangeTracking'
      // 'SecurityInsights'
    ]
  : [
      // 'VMInsights'
      // 'Security'
      // 'ServiceMap'
      'ChangeTracking'
    ]

var events = [
  'System'
  'Application'
]

resource log 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource solution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [
  for solution in solutions: {
    name: '${solution}(${log.name})'
    tags: tags
    location: location
    plan: {
      name: '${solution}(${log.name})'
      promotionCode: ''
      product: 'OMSGallery/${solution}'
      publisher: 'Microsoft'
    }
    properties: {
      workspaceResourceId: log.id
      containedResources: []
    }
  }
]

resource dataSources 'Microsoft.OperationalInsights/workspaces/dataSources@2025-07-01' = [
  for event in events: {
    parent: log
    name: event
    kind: 'WindowsEvent'
    properties: {
      eventLogName: event
      eventTypes: [
        {
          eventType: 'Error'
        }
        {
          eventType: 'Warning'
        }
      ]
    }
  }
]

resource ag 'Microsoft.Insights/actionGroups@2024-10-01-preview' = {
  name: 'ag-mail'
  location: location
  properties: {
    enabled: true
    groupShortName: 'ag-mail'
    emailReceivers: []
  }
}

resource vm_services 'microsoft.insights/scheduledqueryrules@2025-01-01-preview' = {
  name: 'vm-services-alert-01'
  location: location
  kind: 'LogAlert'
  properties: {
    displayName: 'vm-services-alert-01'
    description: 'change tracking'
    severity: 3
    enabled: true
    evaluationFrequency: 'PT10M'
    scopes: [
      log.id
    ]
    targetResourceTypes: [
      'Microsoft.OperationalInsights/workspaces'
    ]
    windowSize: 'PT10M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: 'ConfigurationChange\n| where SvcStartupType == "Auto" and SvcState == "Stopped" and SvcName !in ("sppsvc")\n| project\n    NameDate=strcat(Computer, "_", SvcName, "_", datetime_add(\'hour\', 2, TimeGenerated)),\n    TimeGenerated,\n    SvcState,\n    ConfigChangeType,\n    SvcDisplayName,\n    SvcPath\n| where  TimeGenerated > ago(30m)\n'
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'NameDate'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThan'
          threshold: json('0')
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    autoMitigate: false
    actions: {
      actionGroups: [
        ag.id
      ]
    }
  }
}

resource vm_file 'microsoft.insights/scheduledqueryrules@2025-01-01-preview' = {
  name: 'vm-file-alert-01'
  location: location
  kind: 'LogAlert'
  properties: {
    displayName: 'vm-file-alert-01'
    description: 'change tracking'
    severity: 3
    enabled: true
    evaluationFrequency: 'PT5M'
    scopes: [
      log.id
    ]
    targetResourceTypes: [
      'Microsoft.OperationalInsights/workspaces'
    ]
    windowSize: 'PT10M'
    overrideQueryTimeRange: 'P2D'
    criteria: {
      allOf: [
        {
          query: 'ConfigurationChange\n| where ConfigChangeType == "Files" and Name == "karol.txt"\n| project\n    NameDate=strcat(Computer, "_", Name, "_", datetime_add(\'hour\', 2, TimeGenerated)),\n    TimeGenerated,\n    Name,\n    ConfigChangeType,\n    FileSystemPath\n| where  TimeGenerated > ago(30m)\n'
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'NameDate'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThan'
          threshold: json('0')
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    autoMitigate: false
    actions: {
      actionGroups: [
        ag.id
      ]
    }
  }
}


output id string = log.id
output name string = log.name
