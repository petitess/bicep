targetScope = 'resourceGroup'

param name string
param location string
param aaid string

var tags = resourceGroup().tags

var solutions = [
  'VMInsights'
  'Updates'
  'Security'
  'ServiceMap'
  'ChangeTracking'
]

var windowsEvents = [
  'System'
  'Application'
]

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource worksapeSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in solutions: {
  name: '${solution}(${workspace.name})'
  tags: tags
  location: location
  plan: {
    name: '${solution}(${workspace.name})'
    promotionCode: ''
    product: 'OMSGallery/${solution}'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: workspace.id
    containedResources: []
  }
}]

resource dataSources 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = [for windowsEvent in windowsEvents: {
  parent: workspace
  name: windowsEvent
  kind: 'WindowsEvent'
  properties: {
    eventLogName: windowsEvent
    eventTypes: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
    ]
  }
}]

resource linkedAa 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  name: 'automation'
  parent: workspace
  properties: {
    resourceId: aaid
  }
}

output id string = workspace.id
output name string = workspace.name
output api string = workspace.apiVersion
output logLocation string = workspace.location
