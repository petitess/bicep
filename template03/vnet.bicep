targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param addressPrefixes array
param dnsServers array
param subnets array
param peerings array
param natGateway bool

resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
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
        serviceEndpoints: subnet.properties.serviceEndpoints
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

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-05-01' = [for subnet in subnets: if (subnet.properties.networkSecurityGroup) {
  name: 'nsg-${subnet.name}'
  location: location
  tags: tags
  properties: {
    securityRules: subnet.securityRules
  }
}]

resource rt 'Microsoft.Network/routeTables@2022-05-01' = [for subnet in subnets: if (subnet.properties.routeTable) {
  name: 'rt-${subnet.name}'
  location: location
  tags: tags
  properties: subnet.routeTable.properties
}]

resource ng 'Microsoft.Network/natGateways@2022-05-01' = if (natGateway) {
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

resource pip 'Microsoft.Network/publicIPAddresses@2022-05-01' = if (natGateway) {
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

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-05-01' = [for peering in peerings: {
  parent: vnet
  name: peering.name
  properties: peering.properties
}]

output id string = vnet.id
output name string = vnet.name
output GatewaySubnetId string = vnet.properties.subnets[0].id
output PeSubnetName string = vnet.properties.subnets[3].name
output AppSubnetId string = vnet.properties.subnets[7].id
