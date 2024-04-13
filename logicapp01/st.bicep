targetScope = 'resourceGroup'

param name string
param location string
param sku string
param kind string

var tags = resourceGroup().tags

resource st01 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  tags: tags
  location: location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    defaultToOAuthAuthentication: true
    allowSharedKeyAccess: false
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource table 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  name: 'default'
  parent: st01
}

resource table1 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = {
  name: 'userpasswordexpiration'
  parent: table
  properties: {}
}

output name string = st01.name
output tableName string = table1.name
