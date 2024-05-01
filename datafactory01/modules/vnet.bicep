param prefix string
param location string
param tags object = resourceGroup().tags
param addressPrefixes array
param dnsServers array = []
param subnets array = []
param ddosId string = ''
param logId string = ''
param stId string = ''
param flowLogsEnabled bool

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-${prefix}-01'
  location: location
  tags: tags
  properties: {
    enableDdosProtection: false
    ddosProtectionPlan: !empty(ddosId)
      ? {
          id: ddosId
        }
      : null
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
          serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
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

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = [
  for subnet in subnets: if (contains(subnet, 'rules')) {
    name: 'nsg-${prefix}-${subnet.name}'
    location: location
    tags: tags
    properties: {
      securityRules: contains(subnet, 'defaultRules')
        ? subnet.defaultRules == 'None'
            ? subnet.rules
            : subnet.defaultRules == 'Inbound'
                ? union(
                    subnet.rules,
                    [
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
                    ]
                  )
                : subnet.defaultRules == 'Outbound'
                    ? union(
                        subnet.rules,
                        [
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
                        ]
                      )
                    : union(
                        subnet.rules,
                        [
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
                        ]
                      )
        : union(
            subnet.rules,
            [
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
            ]
          )
    }
  }
]

resource nw 'Microsoft.Network/networkWatchers@2023-09-01' =
  if (false) {
    name: 'nw-${prefix}-01'
    location: location
    tags: tags
  }

resource flowLogs 'Microsoft.Network/networkWatchers/flowLogs@2023-09-01' =
  if (flowLogsEnabled || !empty(logId) || !empty(stId)) {
    parent: nw
    name: 'flowlogs-vnet-${prefix}-01'
    location: location
    tags: tags
    properties: {
      targetResourceId: vnet.id
      storageId: stId
      enabled: flowLogsEnabled
      flowAnalyticsConfiguration: {
        networkWatcherFlowAnalyticsConfiguration: {
          enabled: true
          workspaceResourceId: logId
          trafficAnalyticsInterval: 10
        }
      }
      retentionPolicy: {
        days: 3
        enabled: true
      }
      format: {
        type: 'JSON'
        version: 2
      }
    }
  }

output name string = vnet.name
output id string = vnet.id
output snet object = toObject(vnet.properties.subnets, subnet => subnet.name)
