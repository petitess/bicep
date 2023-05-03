param affix string
param location string
param tags object = resourceGroup().tags
param addressPrefixes array
param dnsServers array = []
param subnets array

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: 'vnet-${affix}-01'
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
        }: null
        routeTable: contains(subnet, 'routes') ? {
          id: rt[i].id
        }: null
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

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = [for subnet in subnets: if(contains(subnet, 'rules')) {
  name: 'nsg-${subnet.name}'
  location: location
  tags: tags
  properties: {
    securityRules: subnet.rules
  }
}]

resource rt 'Microsoft.Network/routeTables@2022-09-01' = [for subnet in subnets: if(contains(subnet, 'routes')) {
name: 'rt-${subnet.name}'
location: location
tags: tags
properties: {
  routes: subnet.routes
}
}]

output snet object = toObject(vnet.properties.subnets, subnet => subnet.name)
