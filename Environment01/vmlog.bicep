targetScope = 'resourceGroup'

param name string
param location string 
param aaid string

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

resource vmlog 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
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

resource vmlogcon 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  name: 'logconnect'
  tags: tags
  kind: 'AzureActivityLog'
  parent: vmlog
  properties: {
    linkedResourceId: subscriptionResourceId('Microsoft.insights/eventTypes', 'management')
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

resource linkedAutomationAccount 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  parent: vmlog
  name: 'automation'
  properties: {
    resourceId: aaid
  }
}

output workspaceId string = vmlog.id
output workspaceName string = vmlog.name
output workspaceApi string = vmlog.apiVersion
output logLocation string = vmlog.location
