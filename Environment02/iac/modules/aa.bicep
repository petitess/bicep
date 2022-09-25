targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags

resource aa 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

output id string = aa.id
output name string = aa.name
