param affix string
param location string
param tags object = resourceGroup().tags
param addressPrefixes array = [
  '10.1.0.0/20'
]
param dnsServers array = []
param subnets array = [
  {
    name: 'snet-aks-01'
    addressPrefix: cidrSubnet(addressPrefixes[0], 24, 0)
  }
  {
    name: 'snet-pep-01'
    addressPrefix: cidrSubnet(addressPrefixes[0], 24, 1)
  }
  {
    name: 'snet-app-01'
    addressPrefix: cidrSubnet(addressPrefixes[0], 24, 2)
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
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

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = [for subnet in subnets: if(contains(subnet, 'rules')) {
  name: 'nsg-${subnet.name}'
  location: location
  tags: tags
  properties: {
    securityRules: subnet.rules
  }
}]

resource rt 'Microsoft.Network/routeTables@2022-11-01' = [for subnet in subnets: if(contains(subnet, 'routes')) {
name: 'rt-${subnet.name}'
location: location
tags: tags
properties: {
  routes: subnet.routes
}
}]

output snet object = toObject(vnet.properties.subnets, subnet => subnet.name)
