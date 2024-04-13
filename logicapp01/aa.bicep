targetScope = 'resourceGroup'

param name string
param location string

var tags = resourceGroup().tags

resource aa 'Microsoft.Automation/automationAccounts@2023-11-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

output id string = aa.id
output name string = aa.name
output principalId string = aa.identity.principalId
