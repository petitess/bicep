targetScope = 'resourceGroup'

param name string
param location string
param snetOutboundId string
param snetPepId string = ''

var tags = resourceGroup().tags

var slotsWithPep = {
  main: 'sites'
  slot01: 'sites-slot01'
  slot02: 'sites-slot02'
}

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

resource slot 'Microsoft.Web/sites/slots@2022-09-01' = [for slot in items(slotsWithPep): if(slot.key != 'main') {
  name: slot.key
  parent: app
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
}]

resource pep 'Microsoft.Network/privateEndpoints@2022-11-01' = [for pep in items(slotsWithPep): if (!empty(snetPepId)) {
  name: 'pep-${app.name}-${pep.key}'
  location: location
  tags: tags
  dependsOn: [
    slot
  ]
  properties: {
    customNetworkInterfaceName: 'nic-${app.name}-${pep.key}'
    subnet: {
      id: snetPepId
    }
    privateLinkServiceConnections: [
      {
        name: app.name
        properties: {
          privateLinkServiceId: app.id
          groupIds: [
            pep.value
          ]
        }
      }
    ]
  }
}]
