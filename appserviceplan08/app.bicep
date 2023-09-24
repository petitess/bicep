targetScope = 'resourceGroup'

param name string
param location string
param snetOutboundId string
param snetPepId string = ''
param rgDns string

var tags = resourceGroup().tags

resource plan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'plan-${name}'
  location: location
  tags: tags
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {}
}

resource app 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    enabled: true
    publicNetworkAccess: 'Disabled'
    siteConfig: {
      phpVersion: 'OFF'
      netFrameworkVersion: 'v7.0'
      ftpsState: 'FtpsOnly'
      alwaysOn: false
    }
    serverFarmId: plan.id
    clientAffinityEnabled: true
    httpsOnly: true
    virtualNetworkSubnetId: snetOutboundId
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2023-05-01' = if (!empty(snetPepId)) {
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

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = if (!empty(snetPepId)) {
  name: 'dns-${app.name}'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config01'
        properties: {
          privateDnsZoneId: resourceId(rgDns, 'Microsoft.Network/privateDnsZones', 'privatelink.azurewebsites.net')
        }
      }
    ]
  }
}

output serverfarmsid string = plan.id
output serverfarmsname string = plan.name
