targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param sku string = 'PerGB2018'
param retentionInDays int = 30

resource log 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Disabled'
  }
}

output id string = log.id
output name string = log.name
output api string = log.apiVersion
output logLocation string = log.location
