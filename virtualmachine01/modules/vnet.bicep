param prefix string
param location string
param tags object = resourceGroup().tags
param addressPrefixes array
param dnsServers array = []
param subnets array = []
param allowedSubnets object

resource vnet 'Microsoft.Network/virtualNetworks@2025-01-01' = {
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
    subnets: [
      for (subnet, i) in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
          delegations: contains(subnet, 'delegation')
            ? [
                {
                  name: subnet.delegation
                  properties: {
                    serviceName: subnet.delegation
                  }
                }
              ]
            : []
          serviceEndpoints: subnet.?serviceEndpoints ?? []
          networkSecurityGroup: contains(subnet, 'rules')
            ? {
                id: nsg[i].id
              }
            : null
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2025-01-01' = [
  for subnet in subnets: if (contains(subnet, 'rules')) {
    name: 'nsg-${prefix}-${subnet.name}'
    location: location
    tags: tags
    properties: {
      securityRules: contains(subnet, 'defaultRules')
        ? subnet.defaultRules == 'None'
            ? subnet.rules
            : subnet.defaultRules == 'Inbound'
                ? union(subnet.rules, [
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
                  ])
                : subnet.defaultRules == 'Outbound'
                    ? union(subnet.rules, [
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
                    : union(subnet.rules, [
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
                      ])
        : union(subnet.rules, [
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
  }
]

resource nw 'Microsoft.Network/networkWatchers@2025-01-01' = if (false) {
  name: 'nw-${prefix}-01'
  location: location
  tags: tags
}

output name string = vnet.name
output id string = vnet.id
output subnets array = vnet.properties.subnets
