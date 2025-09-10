targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param sku resourceInput<'Microsoft.OperationalInsights/workspaces@2021-06-01'>.properties.sku.name = 'PerGB2018'
param retentionInDays int
param solutions ('VMInsights' | 'Updates' | 'Security' | 'ServiceMap' | 'ChangeTracking')[]
param events ('System' | 'Application')[]

resource log 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
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

resource dataSources 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = [
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

output id string = log.id
output name string = log.name
output api string = log.apiVersion
output logLocation string = log.location
