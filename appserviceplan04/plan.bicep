targetScope = 'resourceGroup'

param name string
param location string
param snetOutboundId string
param snetPepId string = ''

var tags = resourceGroup().tags

resource plan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  properties: {}
}

resource app 'Microsoft.Web/sites@2022-09-01' = {
  name: 'app-${name}' 
  location: location
  tags: tags
  properties: {
    enabled: true
    publicNetworkAccess: 'Disabled'
    siteConfig: {
      phpVersion: 'OFF'
      netFrameworkVersion: 'v7.0'
      ftpsState: 'FtpsOnly'
      alwaysOn: true
    }
    serverFarmId: plan.id
    clientAffinityEnabled: true
    httpsOnly: true
    virtualNetworkSubnetId: snetOutboundId
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2022-09-01' = if(!empty(snetPepId)) {
  name: 'pep-${app.name}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-${app.name}'
    subnet: {
      id: snetPepId
    }
    privateLinkServiceConnections: [
      {
        name: app.name
        properties: {
          privateLinkServiceId: app.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

output serverfarmsid string = plan.id
output serverfarmsname string = plan.name

