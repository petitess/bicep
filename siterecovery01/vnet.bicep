targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param addressPrefixes array
param dnsServers array
param subnets array
param peerings array

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
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: contains(subnet, 'networkSecurityGroup') ? {
          id: nsg[i].id
        } : null
        routeTable: contains(subnet, 'routeTable') ? {
          id: rt[i].id
        } : null
      }
    }]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = [for subnet in subnets: if (contains(subnet, 'networkSecurityGroup')) {
  name: 'nsg-${subnet.name}'
  location: location
  tags: tags
  properties: {
    securityRules: subnet.securityRules
  }
}]

resource rt 'Microsoft.Network/routeTables@2023-04-01' = [for subnet in subnets: if (contains(subnet, 'routeTable')) {
  name: 'rt-${subnet.name}'
  location: location
  tags: tags
  properties: subnet.routeTable.properties
}]

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = [for peering in peerings: {
  parent: vnet
  name: peering.name
  properties: peering.properties
}]

output id string = vnet.id
output name string = vnet.name
output snet object = toObject(vnet.properties.subnets, subnet => subnet.name)
