param name string
param tags object = resourceGroup().tags
param sku string = 'perGB2018'
param retentionInDays int = 30

resource log 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: name
  location: resourceGroup().location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
  }
}

output id string = log.id
output name string = log.name
output api string = log.apiVersion
output logLocation string = log.location
