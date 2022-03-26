targetScope = 'resourceGroup'

param name string
param location string
param addressPrefixes array
param dnsServers array
param subnets array
param natGateway bool

var tags = resourceGroup().tags

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
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

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' = [for subnet in subnets: if (subnet.properties.networkSecurityGroup) {
  name: 'nsg-${subnet.name}'
  location: location
  tags: tags
  properties: {
    securityRules: subnet.securityRules
  }
}]

resource rt 'Microsoft.Network/routeTables@2021-03-01' = [for subnet in subnets: if (subnet.properties.networkSecurityGroup) {
  name: 'rt-${subnet.name}'
  location: location
  tags: tags
  properties: subnet.routeTable.properties
}]

resource ng 'Microsoft.Network/natGateways@2021-03-01' = if (natGateway) {
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

resource pip 'Microsoft.Network/publicIPAddresses@2021-03-01' = if (natGateway) {
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

output vnetId string = vnet.id
output vnetName string = vnet.name
