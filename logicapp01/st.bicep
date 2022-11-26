targetScope = 'resourceGroup'

param name string
param location string
param sku string
param kind string

var tags = resourceGroup().tags

resource st01 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: name
  tags: tags
  location: location
  sku: {
    name:  sku
  }
  kind: kind
  properties: {
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource table 'Microsoft.Storage/storageAccounts/tableServices@2022-05-01' = {
  name: 'default'
  parent: st01
}

resource table1 'Microsoft.Storage/storageAccounts/tableServices/tables@2022-05-01' = {
  name: 'userpasswordexpiration'
  parent: table
  properties: {}
}

output stname string = st01.name
output tablename string = table1.name
