targetScope = 'resourceGroup'

param name string
param location string
param SubnetId string

var tags = resourceGroup().tags

resource plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  properties: {}
}

resource app 'Microsoft.Web/sites@2022-03-01' = {
  name: '${name}-app' 
  location: location
  tags: tags
  properties: {
    siteConfig: {
      phpVersion: 'OFF'
      netFrameworkVersion: 'v7.0'
      ftpsState: 'FtpsOnly'
      alwaysOn: true
    }
    serverFarmId: plan.id
    clientAffinityEnabled: true
    httpsOnly: true
    virtualNetworkSubnetId: SubnetId
  }
}

output serverfarmsid string = plan.id
output serverfarmsname string = plan.name

