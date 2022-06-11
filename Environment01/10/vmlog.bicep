targetScope = 'resourceGroup'

param name string
param location string

var tags = resourceGroup().tags
var windowsEvents = [
  'System'
  'Application'
]
var solutions = [
  'VMInsights'
  'Updates'
  'Security'
  'ServiceMap'
  'ChangeTracking'
]

resource vmlog 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
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

resource dataSources 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = [for windowsEvent in windowsEvents: {
  parent: vmlog
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

resource worksapeSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in solutions: {
  name: '${solution}(${vmlog.name})'
  tags: tags
  location: location
  plan: {
    name: '${solution}(${vmlog.name})'
    promotionCode: ''
    product: 'OMSGallery/${solution}'
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: vmlog.id
    containedResources: []
  }
}]

output workspaceId string = vmlog.id
output workspaceApi string = vmlog.apiVersion
