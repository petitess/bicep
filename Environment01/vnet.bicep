targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param addressPrefixes array
param dnsServers array
param subnets array
param peerings array
param natGateway bool

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    dhcpOptions: {
      dnsServers: dnsServers
    }
    subnets: [for (subnet, i) in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.properties.addressPrefix
        networkSecurityGroup: subnet.properties.networkSecurityGroup ? {
          id: nsg[i].id
        } : null
        routeTable: subnet.properties.routeTable ? {
          id: rt[i].id
        } : null
        natGateway: subnet.properties.natGateway ? {
          id: ng.id
        } : null
        privateEndpointNetworkPolicies: subnet.properties.privateEndpointNetworkPolicies
      }
    }]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = [for subnet in subnets: if (subnet.properties.networkSecurityGroup) {
  name: 'nsg-${subnet.name}'
  location: location
  tags: tags
  properties: {
    securityRules: subnet.securityRules
  }
}]

resource rt 'Microsoft.Network/routeTables@2023-04-01' = [for subnet in subnets: if (subnet.properties.routeTable) {
  name: 'rt-${subnet.name}'
  location: location
  tags: tags
  properties: subnet.routeTable.properties
}]

resource ng 'Microsoft.Network/natGateways@2023-04-01' = if (natGateway) {
  name: 'ng-${name}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: pip.id
      }
    ]
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2023-04-01' = if (natGateway) {
  name: 'pip-ng-${name}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = [for peering in peerings: {
  parent: vnet
  name: peering.name
  properties: peering.properties
}]

//https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-create
//When you create or update a virtual network in your subscription, 
//Network Watcher will be enabled automatically in your Virtual Network's region.
//To opt out of Network Watcher automatic enablement, you can do so by running the following commands:
//Register-AzProviderFeature -FeatureName DisableNetworkWatcherAutocreation -ProviderNamespace Microsoft.Network
//Register-AzResourceProvider -ProviderNamespace Microsoft.Network
 
resource nw 'Microsoft.Network/networkWatchers@2023-04-01' = {
  name: replace(name, 'vnet', 'nw')
  location: location
  tags: tags
  properties:{}
}

output id string = vnet.id
output name string = vnet.name
output snet object = toObject(vnet.properties.subnets, subnet => subnet.name)
