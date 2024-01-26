param prefix string
param location string
param tags object = resourceGroup().tags
param addressPrefixes array
param dnsServers array = []
param subnets array = []
param vnetHubName string = ''
param vnetHubId string = ''
param nextHopIpAddress string = ''
param allowedSubnets object

resource vnet 'Microsoft.Network/virtualNetworks@2023-06-01' = {
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
        delegations: contains(subnet, 'delegation') ? [
          {
            name: subnet.delegation
            properties: {
              serviceName: subnet.delegation
            }
          }
        ] : []
        serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
        routeTable: {
          id: rt[i].id
        }
        networkSecurityGroup: contains(subnet, 'rules') ? {
          id: nsg[i].id
        } : null
        privateEndpointNetworkPolicies: 'Enabled'
      }
    }]
  }

  resource peer 'virtualNetworkPeerings' = if(false) {
    name: 'peer-${vnetHubName}'
    properties: {
      remoteVirtualNetwork: {
        id: vnetHubId
      }
      allowForwardedTraffic: true
      useRemoteGateways: true
    }
  }
}

resource rt 'Microsoft.Network/routeTables@2023-06-01' = [for subnet in subnets: if(false) {
  name: 'rt-${prefix}-${subnet.name}'
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: true
    routes: contains(subnet, 'routes') ? subnet.routes : [
      {
        name: 'udr-default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: nextHopIpAddress
        }
      }
      {
        name: 'udr-vpn-client'
        properties: {
          addressPrefix: '172.31.0.0/16'
          nextHopType: 'VirtualNetworkGateway'
        }
      }
    ]
  }
}]

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-06-01' = [for subnet in subnets: if (contains(subnet, 'rules')) {
  name: 'nsg-${prefix}-${subnet.name}'
  location: location
  tags: tags
  properties: {
    securityRules: contains(subnet, 'defaultRules') ? subnet.defaultRules == 'None' ? subnet.rules : subnet.defaultRules == 'Inbound' ? union(subnet.rules, [
        {
          name: 'nsgsr-allow-avd-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: allowedSubnets.avd
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 4092
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-monitor-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: allowedSubnets.monitor
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 4093
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-vpn-client-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '172.31.0.0/16'
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
            destinationPortRange: '*'
            protocol: 'Tcp'
            priority: 4094
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-vnet-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefixes: addressPrefixes
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
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
          name: 'nsgsr-allow-commonservices-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefixes: addressPrefixes
            sourcePortRange: '*'
            destinationAddressPrefixes: [
              allowedSubnets.sven
              allowedSubnets.sales
            ]
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 4094
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-vnet-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefixes: addressPrefixes
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
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
          name: 'nsgsr-allow-avd-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: allowedSubnets.avd
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 4092
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-monitor-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: allowedSubnets.monitor
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 4093
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-vpn-client-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '172.31.0.0/16'
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
            destinationPortRange: '*'
            protocol: 'Tcp'
            priority: 4094
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-vnet-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefixes: addressPrefixes
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
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
          name: 'nsgsr-allow-commonservices-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefixes: addressPrefixes
            sourcePortRange: '*'
            destinationAddressPrefixes: [
              allowedSubnets.sven
              allowedSubnets.sales
            ]
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 4094
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-vnet-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefixes: addressPrefixes
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
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
          name: 'nsgsr-allow-avd-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: allowedSubnets.avd
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 4092
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-monitor-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: allowedSubnets.monitor
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 4093
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-vpn-client-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '172.31.0.0/16'
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
            destinationPortRange: '*'
            protocol: 'Tcp'
            priority: 4094
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-vnet-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefixes: addressPrefixes
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
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
          name: 'nsgsr-allow-platform-pep-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: '10.100.9.160/27'
            destinationPortRange: '*'
            protocol: '*'
            priority: 4093
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-commonservices-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefixes: addressPrefixes
            sourcePortRange: '*'
            destinationAddressPrefixes: [
              allowedSubnets.sven
              allowedSubnets.sales
            ]
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 4094
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-vnet-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefixes: addressPrefixes
            sourcePortRange: '*'
            destinationAddressPrefixes: addressPrefixes
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

resource nw 'Microsoft.Network/networkWatchers@2023-06-01' = {
  name: 'nw-${prefix}-01'
  location: location
  tags: tags
}

output name string = vnet.name
output id string = vnet.id
output subnets array = vnet.properties.subnets
