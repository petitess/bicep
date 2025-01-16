param name string
param location string
param tags object = resourceGroup().tags
param addressPrefixes array
param dnsServers array = []
param subnets array

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
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
        networkSecurityGroup: contains(subnet, 'rules') ? {
          id: nsg[i].id
        } : null
        routeTable: contains(subnet, 'routes') ? {
          id: rt[i].id
        } : null
        delegations: contains(subnet, 'delegation') ? [
          {
            name: subnet.delegation
            properties: {
              serviceName: subnet.delegation
            }
          }
        ] : []
      }
    }]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = [for subnet in subnets: if (contains(subnet, 'rules')) {
  name: 'nsg-${subnet.name}'
  location: location
  tags: tags
  properties: {
    securityRules: concat(subnet.rules, [
        {
          name: 'nsgsr-deny-all-inbound'
          properties: {
            access: 'Deny'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '*'
            protocol: '*'
            priority: 4096
            direction: 'Inbound'
          }
        }
      ])
  }
}]

resource rt 'Microsoft.Network/routeTables@2024-05-01' = [for subnet in subnets: if (contains(subnet, 'routes')) {
  name: 'rt-${subnet.name}'
  location: location
  tags: tags
  properties: {
    routes: subnet.routes
  }
}]

output name string = vnet.name
output id string = vnet.id
