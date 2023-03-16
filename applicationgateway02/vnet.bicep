param prefix string
param location string
param tags object = resourceGroup().tags
param addressPrefixes array
param dnsServers array = []
param subnets array = []

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: 'vnet-${prefix}-01'
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
        serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
        privateEndpointNetworkPolicies: 'Enabled'
      }
    }]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = [for subnet in subnets: if (contains(subnet, 'rules')) {
  name: 'nsg-${prefix}-${subnet.name}'
  location: location
  tags: tags
  properties: {
    securityRules: contains(subnet, 'defaultRules') ? subnet.defaultRules == 'None' ? subnet.rules : subnet.defaultRules == 'Inbound' ? union(subnet.rules, [
        {
          name: 'nsgsr-allow-snet-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: subnet.addressPrefix
            sourcePortRange: '*'
            destinationAddressPrefix: subnet.addressPrefix
            destinationPortRange: '*'
            protocol: '*'
            priority: 4095
            direction: 'Inbound'
          }
        }
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
      ]) : subnet.defaultRules == 'Outbound' ? union(subnet.rules, [
        {
          name: 'nsgsr-allow-snet-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: subnet.addressPrefix
            sourcePortRange: '*'
            destinationAddressPrefix: subnet.addressPrefix
            destinationPortRange: '*'
            protocol: '*'
            priority: 4095
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-deny-all-outbound'
          properties: {
            access: 'Deny'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '*'
            protocol: '*'
            priority: 4096
            direction: 'Outbound'
          }
        }
      ]) : union(subnet.rules, [
        {
          name: 'nsgsr-allow-snet-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: subnet.addressPrefix
            sourcePortRange: '*'
            destinationAddressPrefix: subnet.addressPrefix
            destinationPortRange: '*'
            protocol: '*'
            priority: 4095
            direction: 'Inbound'
          }
        }
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
        {
          name: 'nsgsr-allow-snet-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: subnet.addressPrefix
            sourcePortRange: '*'
            destinationAddressPrefix: subnet.addressPrefix
            destinationPortRange: '*'
            protocol: '*'
            priority: 4095
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-deny-all-outbound'
          properties: {
            access: 'Deny'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '*'
            protocol: '*'
            priority: 4096
            direction: 'Outbound'
          }
        }
      ]) : union(subnet.rules, [
        {
          name: 'nsgsr-allow-snet-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: subnet.addressPrefix
            sourcePortRange: '*'
            destinationAddressPrefix: subnet.addressPrefix
            destinationPortRange: '*'
            protocol: '*'
            priority: 4095
            direction: 'Inbound'
          }
        }
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
        {
          name: 'nsgsr-allow-snet-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: subnet.addressPrefix
            sourcePortRange: '*'
            destinationAddressPrefix: subnet.addressPrefix
            destinationPortRange: '*'
            protocol: '*'
            priority: 4095
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-deny-all-outbound'
          properties: {
            access: 'Deny'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '*'
            protocol: '*'
            priority: 4096
            direction: 'Outbound'
          }
        }
      ])
  }
}]

output name string = vnet.name
output id string = vnet.id
output snetId object = reduce(vnet.properties.subnets, {}, (cur, next) => union(cur, { '${next.name}': next.id }))

