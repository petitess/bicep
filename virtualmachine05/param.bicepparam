using 'main.bicep'

param param = {
  location: 'SwedenCentral'
  locationAlt: 'WestEurope'
  tags: {
    Application: 'Infra'
    Environment: 'dev'
  }
  avd: {
    description: 'Change to true when an image is prepared. Remove vmimage01 after creating an image'
    sysprepReady: true
    avdcount: 3
    imageVersion: '0.0.2'
    osDiskSizeGB: 128
    vmSize: 'Standard_B2ms'
    subnetName: 'snet-app-test-01'
    privateIPAddress: '10.10.7.'
  }
  vnet01: {
    addressPrefixes: [
      '10.10.0.0/16'
    ]
    dnsServers: []
    peerings: []
    natGateway: false
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.10.0.0/24'
          networkSecurityGroup: false
          routeTable: false
          natGateway: false
          privateEndpointNetworkPolicies: 'Enabled'
        }
        routeTable: {
          properties: {}
        }
        securityRules: []
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.10.1.0/24'
          networkSecurityGroup: false
          routeTable: false
          natGateway: false
          privateEndpointNetworkPolicies: 'Enabled'
        }
        routeTable: {
          properties: {}
        }
        securityRules: []
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.10.2.0/24'
          networkSecurityGroup: true
          routeTable: false
          natGateway: false
          privateEndpointNetworkPolicies: 'Enabled'
        }
        routeTable: {
          properties: {}
        }
        securityRules: [
          {
            name: 'Allow_Inbound_Monitor'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10050'
              sourceAddressPrefix: '10.10.7.11/32'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 500
              direction: 'Inbound'
            }
          }
          {
            name: 'Deny_Inbound_All'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 4096
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Https'
            properties: {
              protocol: 'TCP'
              sourcePortRange: '*'
              destinationPortRange: '443'
              sourceAddressPrefix: 'Internet'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 1000
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_GatewayManager'
            properties: {
              protocol: 'TCP'
              sourcePortRange: '*'
              destinationPortRange: '443'
              sourceAddressPrefix: 'GatewayManager'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 1100
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_AzureLoadBalancer'
            properties: {
              protocol: 'TCP'
              sourcePortRange: '*'
              destinationPortRange: '443'
              sourceAddressPrefix: 'AzureLoadBalancer'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 1200
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_BastionHost'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '8080'
                '5701'
              ]
              sourceAddressPrefix: 'VirtualNetwork'
              destinationAddressPrefix: 'VirtualNetwork'
              access: 'Allow'
              priority: 1300
              direction: 'Inbound'
            }
          }
          {
            name: 'Deny_Outbound_All'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 4096
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_RdpSsh'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '22'
                '3389'
              ]
              sourceAddressPrefix: '*'
              destinationAddressPrefix: 'VirtualNetwork'
              access: 'Allow'
              priority: 1000
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_AzureCloud'
            properties: {
              protocol: 'TCP'
              sourcePortRange: '*'
              destinationPortRange: '443'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: 'AzureCloud'
              access: 'Allow'
              priority: 1100
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_BastionHost'
            properties: {
              protocol: 'TCP'
              sourcePortRange: '*'
              destinationPortRanges: [
                '8080'
                '5701'
              ]
              sourceAddressPrefix: 'VirtualNetwork'
              destinationAddressPrefix: 'VirtualNetwork'
              access: 'Allow'
              priority: 1200
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_SessionInformation'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '80'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: 'Internet'
              access: 'Allow'
              priority: 1300
              direction: 'Outbound'
            }
          }
        ]
      }
      {
        name: 'snet-pe-test-01'
        properties: {
          addressPrefix: '10.10.3.0/24'
          networkSecurityGroup: true
          routeTable: false
          natGateway: false
          privateEndpointNetworkPolicies: 'Disabled'
        }
        routeTable: {
          properties: {}
        }
        securityRules: [
          {
            name: 'Allow_Inbound_Monitor'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10050'
              sourceAddressPrefix: '10.10.7.11/32'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 500
              direction: 'Inbound'
            }
          }
          {
            name: 'Deny_Inbound_All'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 4096
              direction: 'Inbound'
            }
          }
          {
            name: 'Deny_Outbound_All'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 4096
              direction: 'Outbound'
            }
          }
        ]
      }
      {
        name: 'snet-core-test-01'
        properties: {
          addressPrefix: '10.10.4.0/24'
          networkSecurityGroup: true
          routeTable: false
          natGateway: false
          privateEndpointNetworkPolicies: 'Enabled'
        }
        routeTable: {
          properties: {}
        }
        securityRules: [
          {
            name: 'Allow_Inbound_Bastion'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '22'
                '3389'
              ]
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 100
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_ICMP'
            properties: {
              protocol: 'ICMP'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '10.10.5.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 200
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Mgmt'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '22'
                '80'
                '135'
                '139'
                '443'
                '445'
                '1433'
                '3389'
                '5986'
              ]
              sourceAddressPrefix: '10.10.5.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 300
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_ActiveDirectory'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '53'
                '80'
                '88'
                '123'
                '135'
                '137-139'
                '389'
                '445'
                '464'
                '636'
                '3268-3269'
                '5722'
                '9389'
                '49152-65535'
              ]
              sourceAddressPrefixes: [
                '10.10.4.0/24'
                '10.10.5.0/24'
                '10.10.6.0/24'
                '10.10.7.0/24'
                '10.10.8.0/24'
                '10.10.9.0/24'
                '10.10.10.0/24'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 400
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Monitor'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10050'
              sourceAddressPrefix: '10.10.7.11/32'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 500
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_AADDS'
            properties: {
              protocol: 'TCP'
              sourcePortRange: '*'
              destinationPortRange: 5986
              sourceAddressPrefix: 'AzureActiveDirectoryDomainServices'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 600
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_AADDSsync'
            properties: {
              protocol: 'TCP'
              sourcePortRange: '*'
              destinationPortRange: 443
              sourceAddressPrefix: 'AzureActiveDirectoryDomainServices'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 700
              direction: 'Inbound'
            }
          }
          {
            name: 'Deny_Inbound_All'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 4096
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Outbound_ActiveDirectory'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '53'
                '88'
                '123'
                '135'
                '137-139'
                '389'
                '445'
                '464'
                '636'
                '3268-3269'
                '3389'
                '5722'
                '49152-65535'
              ]
              sourceAddressPrefix: '*'
              destinationAddressPrefixes: [
                '10.10.4.0/24'
                '10.10.5.0/24'
                '10.10.6.0/24'
                '10.10.7.0/24'
                '10.10.8.0/24'
                '10.10.9.0/24'
                '10.10.10.0/24'
              ]
              access: 'Allow'
              priority: 400
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Monitor'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10051'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.7.11/32'
              access: 'Allow'
              priority: 500
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Internet'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: 'Internet'
              access: 'Allow'
              priority: 4000
              direction: 'Outbound'
            }
          }
          {
            name: 'Deny_Outbound_All'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 4096
              direction: 'Outbound'
            }
          }
        ]
      }
      {
        name: 'snet-mgmt-test-01'
        properties: {
          addressPrefix: '10.10.5.0/24'
          networkSecurityGroup: true
          routeTable: false
          natGateway: false
          privateEndpointNetworkPolicies: 'Enabled'
        }
        routeTable: {
          properties: {}
        }
        securityRules: [
          {
            name: 'Allow_Inbound_Bastion'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '22'
                '3389'
              ]
              sourceAddressPrefix: '10.10.2.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 100
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_ICMP'
            properties: {
              protocol: 'ICMP'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '10.10.5.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 200
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Mgmt'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '22'
                '80'
                '135'
                '139'
                '443'
                '445'
                '1433'
                '3389'
                '5986'
              ]
              sourceAddressPrefix: '10.10.5.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 300
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_ActiveDirectory'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '53'
                '88'
                '123'
                '135'
                '137-139'
                '389'
                '445'
                '464'
                '636'
                '3268-3269'
                '3389'
                '5722'
                '9389'
                '49152-65535'
              ]
              sourceAddressPrefix: '10.10.4.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 400
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Monitor'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10050'
              sourceAddressPrefix: '10.10.7.11/32'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 500
              direction: 'Inbound'
            }
          }
          {
            name: 'Deny_Inbound_All'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 4096
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Outbound_ICMP'
            properties: {
              protocol: 'ICMP'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.0.0/16'
              access: 'Allow'
              priority: 200
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Mgmt'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '22'
                '80'
                '135'
                '139'
                '443'
                '445'
                '1433'
                '3389'
                '5986'
              ]
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.0.0/16'
              access: 'Allow'
              priority: 300
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_ActiveDirectory'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '53'
                '80'
                '88'
                '123'
                '135'
                '137-139'
                '389'
                '445'
                '464'
                '636'
                '3268-3269'
                '5722'
                '9389'
                '49152-65535'
              ]
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.4.0/24'
              access: 'Allow'
              priority: 400
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Monitor'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10051'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.7.11/32'
              access: 'Allow'
              priority: 500
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Internet'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: 'Internet'
              access: 'Allow'
              priority: 4000
              direction: 'Outbound'
            }
          }
          {
            name: 'Deny_Outbound_All'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 4096
              direction: 'Outbound'
            }
          }
        ]
      }
      {
        name: 'snet-sql-test-01'
        properties: {
          addressPrefix: '10.10.6.0/24'
          networkSecurityGroup: true
          routeTable: false
          natGateway: false
          privateEndpointNetworkPolicies: 'Enabled'
        }
        routeTable: {
          properties: {}
        }
        securityRules: [
          {
            name: 'Allow_Inbound_Bastion'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '22'
                '3389'
              ]
              sourceAddressPrefix: '10.10.2.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 100
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_ICMP'
            properties: {
              protocol: 'ICMP'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '10.10.5.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 200
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Mgmt'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '22'
                '80'
                '135'
                '139'
                '443'
                '445'
                '1433'
                '3389'
                '5986'
              ]
              sourceAddressPrefix: '10.10.5.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 300
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_ActiveDirectory'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '53'
                '88'
                '123'
                '135'
                '137-139'
                '389'
                '445'
                '464'
                '636'
                '3268-3269'
                '3389'
                '5722'
                '9389'
                '49152-65535'
              ]
              sourceAddressPrefix: '10.10.4.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 400
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Monitor'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10050'
              sourceAddressPrefix: '10.10.7.11/32'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 500
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_SQL'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '1433'
              sourceAddressPrefixes: [
                '10.10.7.0/24'
                '10.10.8.0/24'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 1000
              direction: 'Inbound'
            }
          }
          {
            name: 'Deny_Inbound_All'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 4096
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Outbound_ActiveDirectory'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '53'
                '80'
                '88'
                '123'
                '135'
                '137-139'
                '389'
                '445'
                '464'
                '636'
                '3268-3269'
                '5722'
                '9389'
                '49152-65535'
              ]
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.4.0/24'
              access: 'Allow'
              priority: 400
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Monitor'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10051'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.7.11/32'
              access: 'Allow'
              priority: 500
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Internet'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: 'Internet'
              access: 'Allow'
              priority: 4000
              direction: 'Outbound'
            }
          }
          {
            name: 'Deny_Outbound_All'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 4096
              direction: 'Outbound'
            }
          }
        ]
      }
      {
        name: 'snet-app-test-01'
        properties: {
          addressPrefix: '10.10.7.0/24'
          networkSecurityGroup: true
          routeTable: false
          natGateway: false
          privateEndpointNetworkPolicies: 'Enabled'
        }
        routeTable: {
          properties: {}
        }
        securityRules: [
          {
            name: 'Allow_Inbound_Bastion'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '22'
                '3389'
              ]
              sourceAddressPrefix: '10.10.2.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 100
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_ICMP'
            properties: {
              protocol: 'ICMP'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '10.10.5.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 200
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Mgmt'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '22'
                '80'
                '135'
                '139'
                '443'
                '445'
                '1433'
                '3389'
                '5986'
              ]
              sourceAddressPrefix: '10.10.5.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 300
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_ActiveDirectory'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '53'
                '88'
                '123'
                '135'
                '137-139'
                '389'
                '445'
                '464'
                '636'
                '3268-3269'
                '3389'
                '5722'
                '9389'
                '49152-65535'
              ]
              sourceAddressPrefix: '10.10.4.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 400
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Monitor'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10050'
              sourceAddressPrefix: '10.10.7.11/32'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 500
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Zabbix'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10051'
              sourceAddressPrefix: '10.10.0.0/16'
              destinationAddressPrefix: '10.10.7.11/32'
              access: 'Allow'
              priority: 600
              direction: 'Inbound'
            }
          }
          {
            name: 'Deny_Inbound_All'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 4096
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Outbound_ActiveDirectory'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '53'
                '80'
                '88'
                '123'
                '135'
                '137-139'
                '389'
                '445'
                '464'
                '636'
                '3268-3269'
                '5722'
                '9389'
                '49152-65535'
              ]
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.4.0/24'
              access: 'Allow'
              priority: 400
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Monitor'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10051'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.7.11/32'
              access: 'Allow'
              priority: 500
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Zabbix'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10050'
              sourceAddressPrefix: '10.10.7.11/32'
              destinationAddressPrefix: '10.10.0.0/16'
              access: 'Allow'
              priority: 600
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_SQL'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '1433'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.6.0/24'
              access: 'Allow'
              priority: 1000
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Internet'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: 'Internet'
              access: 'Allow'
              priority: 4000
              direction: 'Outbound'
            }
          }
          {
            name: 'Deny_Outbound_All'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 4096
              direction: 'Outbound'
            }
          }
        ]
      }
      {
        name: 'snet-web-test-01'
        properties: {
          addressPrefix: '10.10.8.0/24'
          networkSecurityGroup: true
          routeTable: false
          natGateway: false
          privateEndpointNetworkPolicies: 'Enabled'
        }
        routeTable: {
          properties: {}
        }
        securityRules: [
          {
            name: 'Allow_Inbound_Bastion'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '22'
                '3389'
              ]
              sourceAddressPrefix: '10.10.2.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 100
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_ICMP'
            properties: {
              protocol: 'ICMP'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '10.10.5.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 200
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Mgmt'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '22'
                '80'
                '135'
                '139'
                '443'
                '445'
                '1433'
                '3389'
                '5986'
              ]
              sourceAddressPrefix: '10.10.5.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 300
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_ActiveDirectory'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '53'
                '88'
                '123'
                '135'
                '137-139'
                '389'
                '445'
                '464'
                '636'
                '3268-3269'
                '3389'
                '5722'
                '9389'
                '49152-65535'
              ]
              sourceAddressPrefix: '10.10.4.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 400
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Monitor'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10050'
              sourceAddressPrefix: '10.10.7.11/32'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 500
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Web'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '443'
              sourceAddressPrefix: '10.10.0.0/16'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 1000
              direction: 'Inbound'
            }
          }
          {
            name: 'Deny_Inbound_All'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 4096
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Outbound_ActiveDirectory'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '53'
                '80'
                '88'
                '123'
                '135'
                '137-139'
                '389'
                '445'
                '464'
                '636'
                '3268-3269'
                '5722'
                '9389'
                '49152-65535'
              ]
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.4.0/24'
              access: 'Allow'
              priority: 400
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Monitor'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10051'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.7.11/32'
              access: 'Allow'
              priority: 500
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_SQL'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '1433'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.6.0/24'
              access: 'Allow'
              priority: 1000
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Internet'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: 'Internet'
              access: 'Allow'
              priority: 4000
              direction: 'Outbound'
            }
          }
          {
            name: 'Deny_Outbound_All'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 4096
              direction: 'Outbound'
            }
          }
        ]
      }
    ]
  }
}
