targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param sku string
param retentionInDays int
param solutions array
param events array

resource log 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    retentionInDays: retentionInDays
    publicNetworkAccessForIngestion: 'Disabled' 
    publicNetworkAccessForQuery: 'Disabled'
  }
}

resource solution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in solutions: {
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
}]

resource dataSources 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = [for event in events: {
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
}]

resource pl 'microsoft.insights/privateLinkScopes@2021-07-01-preview' = {
  name: '${log.name}-pl01'
  location: 'global'
  tags: tags
  properties: {
    accessModeSettings: {
      ingestionAccessMode: 'PrivateOnly'
      queryAccessMode: 'PrivateOnly'
      exclusions: []
    }
  }
}

resource plres 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  name: uniqueString(pl.name)
  parent: pl
  properties: {
    linkedResourceId: log.id
  }
}

output id string = log.id
output name string = log.name
output api string = log.apiVersion
output logLocation string = log.location
output plname string = pl.name
