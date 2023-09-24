using './main.bicep'

param param = {
  location: 'SwedenCentral'
  locationAlt: 'WestEurope'
  tags: {
    Application: 'Infra'
    Environment: 'Prod'
  }
  privateZones: [
    'privatelink.azurewebsites.net'
    'privatelink.database.windows.net'
  ]
  vnet: {
    addressPrefixes: [
      '10.10.0.0/16'
    ]
    dnsServers: [
      '10.10.4.11'
    ]
    peerings: []
    natGateway: true
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
        name: 'snet-pe-prod-01'
        properties: {
          addressPrefix: '10.10.3.0/24'
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
            name: 'Allow_Inbound_Mgmt_Appdeployment01'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '443'
              sourceAddressPrefixes: [ '10.10.5.11/32'
                '10.10.10.0/24'
              ]
              destinationAddressPrefix: '10.10.3.8/32'
              access: 'Allow'
              priority: 600
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Mgmt_Appdeployment01_Sql'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '1433'
              sourceAddressPrefixes: [ '10.10.5.11/32'
                '10.10.10.0/24'
              ]
              destinationAddressPrefix: '10.10.3.9/32'
              access: 'Allow'
              priority: 700
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Appdeployment01_Sql'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '1433'
              sourceAddressPrefix: '10.10.11.0/24'
              destinationAddressPrefix: '10.10.3.9/32'
              access: 'Allow'
              priority: 800
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
        name: 'snet-core-prod-01'
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
            name: 'Allow_Inbound_ICMP_OLD'
            properties: {
              protocol: 'ICMP'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
                '10.113.0.0/24'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 250
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
                '67'
                '80'
                '88'
                '123'
                '135'
                '137-139'
                '389'
                '443'
                '445'
                '464'
                '636'
                '3268-3269'
                '5722'
                '5985'
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
                '10.15.0.0/24'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 400
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_ActiveDirectory_OLD'
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
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 450
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
            name: 'Allow_Inbound_RDP_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 600
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_RDP_P2S'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefix: '10.15.0.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 700
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_LB'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: 'AzureLoadBalancer'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 800
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
            name: 'Allow_Outbound_ActiveDirectory_OLD'
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
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 450
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
            name: 'Allow_Outbound_Sjunet'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefixes: [
                '213.189.127.54/32'
                '213.189.126.58/32'
                '82.136.176.196/32'
              ]
              access: 'Allow'
              priority: 600
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
        name: 'snet-mgmt-prod-01'
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
            name: 'Allow_Inbound_ActiveDirectory_OLD'
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
              sourceAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 450
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
            name: 'Allow_Inbound_Files'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '445'
              sourceAddressPrefix: '10.10.0.0/16'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 600
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_RDP_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 700
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_PrivateEndpoint'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '443'
              sourceAddressPrefix: '10.10.5.0/24'
              destinationAddressPrefix: '10.10.3.0/24'
              access: 'Allow'
              priority: 800
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_RDP_P2S'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefix: '10.15.0.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 900
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_CTX_VDA_MGMT'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '135'
                '443'
                '445'
                '1494'
                '2598'
                '2071'
                '6901'
                '6902'
                '6905'
                '6910-6969'
                '49152-65535'
              ]
              sourceAddressPrefix: '10.10.9.0/24'
              destinationAddressPrefix: '10.10.5.0/24'
              access: 'Allow'
              priority: 1000
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_LB'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: 'AzureLoadBalancer'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 1100
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_ADC'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '3003'
                '3008'
                '3009'
              ]
              sourceAddressPrefix: '10.10.0.0/16'
              destinationAddressPrefixes: [
                '10.10.5.200'
                '10.10.5.201'
                '10.10.5.205'
                '10.10.5.206'
              ]
              access: 'Allow'
              priority: 1200
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Mgmt_VPN_Test'
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
              sourceAddressPrefix: '10.25.0.0/16'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 1300
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
            name: 'Allow_Outbound_ICMP_Internet'
            properties: {
              protocol: 'ICMP'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: 'Internet'
              access: 'Allow'
              priority: 100
              direction: 'Outbound'
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
            name: 'Allow_Outbound_ActiveDirectory_OLD'
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
              destinationAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 450
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
            name: 'Allow_Outbound_Rdp_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefix: '*'
              destinationAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 600
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_watchguard_test'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.114.0.0/24'
              access: 'Allow'
              priority: 650
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_PrivateEndpoint'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '443'
              sourceAddressPrefix: '10.10.5.0/24'
              destinationAddressPrefix: '10.10.3.0/24'
              access: 'Allow'
              priority: 700
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_CTX'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '135'
                '443'
                '445'
                '1494'
                '2598'
                '8008'
                '6910-6969'
                '16500-16509'
                '49152-65535'
              ]
              sourceAddressPrefix: '10.10.5.0/24'
              destinationAddressPrefix: '10.10.9.0/24'
              access: 'Allow'
              priority: 800
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_ADC'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '3003'
                '3008'
                '3009'
              ]
              sourceAddressPrefixes: [
                '10.10.5.200'
                '10.10.5.201'
                '10.10.5.205'
                '10.10.5.206'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 900
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_WatchGuard'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '8080'
              sourceAddressPrefix: '10.10.5.11'
              destinationAddressPrefix: '10.114.0.1'
              access: 'Allow'
              priority: 1000
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_J4_Mgmt'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '18080'
                '18081'
              ]
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.8.0/24'
              access: 'Allow'
              priority: 1100
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Appdeployment'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '443'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.3.8/32'
              access: 'Allow'
              priority: 1200
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Appdeployment_Sql'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '1433'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.3.9/32'
              access: 'Allow'
              priority: 1300
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
        name: 'snet-sql-prod-01'
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
            name: 'Allow_Inbound_ICMP_OLD'
            properties: {
              protocol: 'ICMP'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
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
            name: 'Allow_Inbound_RDP_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 600
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_CTX_SQL'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '1433'
                '1434'
              ]
              sourceAddressPrefixes: [
                '10.10.9.0/24'
                '10.10.10.0/24'
              ]
              destinationAddressPrefix: '10.10.6.11/32'
              access: 'Allow'
              priority: 700
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_RDP_P2S'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefix: '10.15.0.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 800
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
                '10.212.0.0/16'
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 1000
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_SQL_SSRS'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '80'
              sourceAddressPrefix: '10.10.8.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 1100
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
            name: 'Allow_Outbound_File_Mgmt'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '445'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.5.0/24'
              access: 'Allow'
              priority: 600
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_ActiveDirectory_OLD'
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
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 700
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_File'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '445'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.7.12/32'
              access: 'Allow'
              priority: 800
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
        name: 'snet-app-prod-01'
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
            name: 'Allow_Inbound_LB'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: 'AzureLoadBalancer'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 700
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_CPM_FILE'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '445'
              sourceAddressPrefixes: [
                '10.10.9.17/32'
                '10.10.9.18/32'
              ]
              destinationAddressPrefix: '10.10.7.12/32'
              access: 'Allow'
              priority: 800
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_VDA_FILE'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '445'
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefix: '10.10.7.12/32'
              access: 'Allow'
              priority: 900
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_WEB_FILE'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '445'
              sourceAddressPrefix: '10.10.8.0/24'
              destinationAddressPrefix: '10.10.7.12/32'
              access: 'Allow'
              priority: 1000
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Print_Customer'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '443'
                '9100'
              ]
              sourceAddressPrefixes: [
                '10.212.0.0/16'
                '10.112.0.0/16'
                '10.114.0.0/24'
                '10.201.110.0/24'
                '192.168.35.0/24'
                '192.168.30.0/24'
                '192.168.10.0/24'
              ]
              destinationAddressPrefix: '10.10.7.13'
              access: 'Allow'
              priority: 1100
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Print_VDA'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '443'
                '445'
                '9100'
              ]
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefix: '10.10.7.13'
              access: 'Allow'
              priority: 1150
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_File_Customer'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '445'
              sourceAddressPrefixes: [
                '10.212.0.0/16'
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              destinationAddressPrefix: '10.10.7.12'
              access: 'Allow'
              priority: 1200
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_File_SQL'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '445'
              sourceAddressPrefix: '10.10.6.12'
              destinationAddressPrefix: '10.10.7.12'
              access: 'Allow'
              priority: 1300
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_RDP_P2S'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefix: '10.15.0.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 1400
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
            name: 'Allow_Outbound_ActiveDirectory_OLD'
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
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 450
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
            name: 'Allow_Outbound_Print_S2S_ICMP'
            properties: {
              protocol: 'ICMP'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '10.10.7.13'
              destinationAddressPrefixes: [
                '10.201.110.0/24'
                '192.168.35.0/24'
                '192.168.30.0/24'
                '192.168.10.0/24'
              ]
              access: 'Allow'
              priority: 625
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Print_S2S'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '10.10.7.13'
              destinationAddressPrefixes: [
                '10.201.110.0/24'
                '192.168.35.0/24'
                '192.168.30.0/24'
                '192.168.10.0/24'
              ]
              access: 'Allow'
              priority: 650
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Print_Customer'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '10.10.7.13'
              destinationAddressPrefixes: [
                '10.212.0.0/16'
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 700
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Print_VDA'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '443'
                '445'
                '9100'
              ]
              sourceAddressPrefix: '10.10.7.13'
              destinationAddressPrefix: '10.10.10.0/24'
              access: 'Allow'
              priority: 800
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
        name: 'snet-web-prod-01'
        properties: {
          addressPrefix: '10.10.8.0/24'
          networkSecurityGroup: true
          routeTable: false
          natGateway: true
          privateEndpointNetworkPolicies: 'Enabled'
        }
        routeTable: {
          properties: {
            disableBgpRoutePropagation: false
            routes: []
          }
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
            name: 'Allow_Inbound_LoginCTX_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '8443'
                '18080'
                '18081'
                '443'
              ]
              sourceAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 600
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_RDP_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 700
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_8080_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '8080'
              sourceAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 710
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_RDP_P2S'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefix: '10.15.0.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 800
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Web_WTB'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '8080'
                '8082'
                '8083'
                '8084'
                '8087'
                '8089'
                '8092'
                '8093'
                '18092'
              ]
              sourceAddressPrefix: 'Internet'
              destinationAddressPrefix: '10.10.8.16/32'
              access: 'Allow'
              priority: 900
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Web'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '443'
              sourceAddressPrefix: 'Internet'
              destinationAddressPrefix: '10.10.8.0/24'
              access: 'Allow'
              priority: 1000
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_WTB'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '8080'
                '8082'
                '8083'
                '8084'
                '8087'
                '8089'
                '8092'
                '8093'
                '18092'
              ]
              sourceAddressPrefix: '10.10.8.0/24'
              destinationAddressPrefix: '10.10.8.0/24'
              access: 'Allow'
              priority: 1100
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_LB'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: 'AzureLoadBalancer'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 1200
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Web_ADC_CSR'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '443'
              ]
              sourceAddressPrefix: 'Internet'
              destinationAddressPrefix: 'Internet'
              access: 'Allow'
              priority: 1300
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_VDA_J4'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '8080'
                '18080'
                '18081'
              ]
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefix: '10.10.8.0/24'
              access: 'Allow'
              priority: 1400
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_J4_Centrumpraktiken'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '9083'
              ]
              sourceAddressPrefix: 'Internet'
              destinationAddressPrefix: '10.10.8.17/32'
              access: 'Allow'
              priority: 1500
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_J4_Nordstan'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '9087'
              ]
              sourceAddressPrefix: 'Internet'
              destinationAddressPrefix: '10.10.8.20/32'
              access: 'Allow'
              priority: 1510
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_J4_Rävlanda'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '9089'
              ]
              sourceAddressPrefix: 'Internet'
              destinationAddressPrefix: '10.10.8.21/32'
              access: 'Allow'
              priority: 1520
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_J4_Primapraktiken'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '9092'
              ]
              sourceAddressPrefix: 'Internet'
              destinationAddressPrefix: '10.10.8.22/32'
              access: 'Allow'
              priority: 1530
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_J4_Läkarhuset'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '9093'
              ]
              sourceAddressPrefix: 'Internet'
              destinationAddressPrefix: '10.10.8.23/32'
              access: 'Allow'
              priority: 1540
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_J4_MariaAlbertsVC'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '9084'
              ]
              sourceAddressPrefix: 'Internet'
              destinationAddressPrefix: '10.10.8.19/32'
              access: 'Allow'
              priority: 1600
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_J4_Kusten'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '9082'
              ]
              sourceAddressPrefix: 'Internet'
              destinationAddressPrefix: '10.10.8.14/32'
              access: 'Allow'
              priority: 1700
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_J4_Improve_Rehab'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '9086'
              ]
              sourceAddressPrefix: 'Internet'
              destinationAddressPrefix: '10.10.8.18/32'
              access: 'Allow'
              priority: 1800
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_J4_Mgmt'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '18080'
                '18081'
              ]
              sourceAddressPrefix: '10.10.5.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 1900
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_J4_Customer_Login'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '18080'
              sourceAddressPrefix: '10.212.0.0/16'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 2000
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
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 200
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
            name: 'Allow_Outbound_ActiveDirectory_OLD'
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
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 450
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
            name: 'Allow_Outbound_LB'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: 'AzureLoadBalancer'
              destinationAddressPrefix: '*'
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
            name: 'Allow_Outbound_SQL_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '1433'
              sourceAddressPrefix: '*'
              destinationAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 1050
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_ICMP_OLD'
            properties: {
              protocol: 'ICMP'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 1060
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_8080_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '8080'
              sourceAddressPrefix: '*'
              destinationAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 1070
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_SMTP_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '25'
              sourceAddressPrefix: '10.10.8.16'
              destinationAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 1080
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Any_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 1090
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_File'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '445'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.7.0/24'
              access: 'Allow'
              priority: 1100
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_SQL_SSRS'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '80'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.6.0/24'
              access: 'Allow'
              priority: 1200
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_WTB'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '8080'
                '8082'
                '8083'
                '8084'
                '8087'
                '8089'
                '8092'
                '8093'
                '18092'
              ]
              sourceAddressPrefix: '10.10.8.0/24'
              destinationAddressPrefix: '10.10.8.0/24'
              access: 'Allow'
              priority: 1300
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_ADC'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '3003'
                '3008'
                '3009'
              ]
              sourceAddressPrefixes: [
                '10.10.8.8'
                '10.10.8.9'
                '10.10.8.205'
                '10.10.8.206'
              ]
              destinationAddressPrefix: '*'
              access: 'Deny'
              priority: 1400
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
        name: 'snet-ctx-prod-01'
        properties: {
          addressPrefix: '10.10.9.0/24'
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
              sourceAddressPrefixes: [
                '10.10.5.0/24'
                '10.10.9.0/24'
              ]
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
            name: 'Allow_Inbound_CTX'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '67'
                '69'
                '80'
                '443'
                '445'
                '808'
                '1494'
                '2071'
                '2598'
                '4011'
                '7279'
                '8082-8083'
                '27000'
                '54321'
                '54322'
                '54323'
                '6890-6969'
              ]
              sourceAddressPrefix: '10.10.9.0/24'
              destinationAddressPrefix: '10.10.9.0/24'
              access: 'Allow'
              priority: 600
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_RDP'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefix: '10.15.0.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 700
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_CTX_VDA'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '135'
                '443'
                '445'
                '6910-6969'
                '49152-65535'
              ]
              sourceAddressPrefixes: [
                '10.10.10.0/24'
                '10.10.5.0/24'
              ]
              destinationAddressPrefix: '10.10.9.0/24'
              access: 'Allow'
              priority: 800
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_StoreFront'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '443'
              sourceAddressPrefixes: [
                '10.10.8.8/32'
                '10.10.8.9/32'
                '10.10.8.205/32'
                '10.10.8.206/32'
              ]
              destinationAddressPrefixes: [
                '10.10.9.13/32'
                '10.10.9.14/32'
              ]
              access: 'Allow'
              priority: 900
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_LB'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: 'AzureLoadBalancer'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 1000
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_CTX_CPM'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '135'
                '139'
                '443'
                '445'
                '7750'
                '7751'
                '7771'
              ]
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefixes: [
                '10.10.9.17/32'
                '10.10.9.18/32'
              ]
              access: 'Allow'
              priority: 1100
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
                '67'
                '80'
                '88'
                '123'
                '135'
                '137-139'
                '389'
                '445'
                '443'
                '464'
                '636'
                '3268-3269'
                '5722'
                '5985'
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
            name: 'Allow_Outbound_ActiveDirectory_OLD'
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
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 450
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
            name: 'Allow_Outbound_File'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '445'
              sourceAddressPrefix: '*'
              destinationAddressPrefixes: [
                '10.10.5.0/24'
                '10.10.7.12/32'
              ]
              access: 'Allow'
              priority: 600
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_CTX'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '67'
                '69'
                '80'
                '443'
                '445'
                '808'
                '1494'
                '2071'
                '2598'
                '4011'
                '7279'
                '8082-8083'
                '27000'
                '54321'
                '54322'
                '54323'
                '6890-6969'
              ]
              sourceAddressPrefix: '10.10.9.0/24'
              destinationAddressPrefix: '10.10.9.0/24'
              access: 'Allow'
              priority: 700
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_PVS_SQL'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '1433'
                '1434'
              ]
              sourceAddressPrefix: '10.10.9.0/24'
              destinationAddressPrefix: '10.10.6.11/32'
              access: 'Allow'
              priority: 800
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_PVS_LIC_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '27000'
                '7279'
                '8082'
                '8083'
                '80'
              ]
              sourceAddressPrefix: '10.10.9.0/24'
              destinationAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 900
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_CTX_SQL_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '1433'
              sourceAddressPrefix: '10.10.9.0/24'
              destinationAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 1000
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_CTX_VDA'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '443'
                '1494'
                '2598'
                '2071'
                '6901'
                '6902'
                '6905'
                '8008'
                '6910-6969'
                '16500-16509'
                '54321-54323'
              ]
              sourceAddressPrefix: '10.10.9.0/24'
              destinationAddressPrefixes: [
                '10.10.10.0/24'
                '10.10.5.0/24'
              ]
              access: 'Allow'
              priority: 1100
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_CPM_SQL'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '1433'
              sourceAddressPrefixes: [
                '10.10.9.17/32'
                '10.10.9.18/32'
              ]
              destinationAddressPrefix: '10.10.6.11/32'
              access: 'Allow'
              priority: 1200
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_CPM_VDA'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '135'
                '139'
                '443'
                '445'
                '7750'
                '7751'
                '7771'
              ]
              sourceAddressPrefixes: [
                '10.10.9.17/32'
                '10.10.9.18/32'
              ]
              destinationAddressPrefix: '10.10.10.0/24'
              access: 'Allow'
              priority: 1300
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_ICMP'
            properties: {
              protocol: 'ICMP'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.9.0/24'
              access: 'Allow'
              priority: 3000
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
        name: 'snet-vda-prod-01'
        properties: {
          addressPrefix: '10.10.10.0/24'
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
              sourceAddressPrefixes: [
                '10.10.5.0/24'
                '10.10.10.0/24'
              ]
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
            name: 'Allow_Inbound_CTX_VDA'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '135'
                '443'
                '445'
                '1494'
                '2598'
                '2071'
                '6901'
                '6902'
                '6905'
                '6910-6969'
                '49152-65535'
              ]
              sourceAddressPrefixes: [
                '10.10.9.0/24'
                '10.10.10.0/24'
              ]
              destinationAddressPrefix: '10.10.10.0/24'
              access: 'Allow'
              priority: 600
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_RDP_P2S'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefix: '10.15.0.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 700
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_LB'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: 'AzureLoadBalancer'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 800
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Web_ADC'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '3003'
                '3008'
                '3009'
              ]
              sourceAddressPrefix: '10.10.0.0/16'
              destinationAddressPrefixes: [
                '10.10.10.200'
                '10.10.10.201'
                '10.10.10.205'
                '10.10.10.206'
              ]
              access: 'Allow'
              priority: 900
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_CTX_CPM'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '135'
                '139'
                '443'
                '445'
                '7750'
                '7751'
                '7771'
              ]
              sourceAddressPrefix: '10.10.9.0/24'
              destinationAddressPrefix: '10.10.10.0/24'
              access: 'Allow'
              priority: 1000
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_Print'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '443'
                '445'
                '9100'
              ]
              sourceAddressPrefix: '10.10.7.13'
              destinationAddressPrefix: '10.10.10.0/24'
              access: 'Allow'
              priority: 1100
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
                '67'
                '80'
                '88'
                '123'
                '135'
                '137-139'
                '389'
                '445'
                '443'
                '464'
                '636'
                '3268-3269'
                '5722'
                '5985'
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
            name: 'Allow_Outbound_ActiveDirectory_OLD'
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
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 450
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
            name: 'Allow_Outbound_File'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '445'
              sourceAddressPrefix: '*'
              destinationAddressPrefixes: [
                '10.10.5.0/24'
                '10.10.7.12/32'
              ]
              access: 'Allow'
              priority: 600
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_CTX'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '135'
                '443'
                '445'
                '6910-6969'
                '49152-65535'
              ]
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefix: '10.10.9.0/24'
              access: 'Allow'
              priority: 700
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_CTX_SQL'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '1433'
                '1434'
              ]
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefix: '10.10.6.11/32'
              access: 'Allow'
              priority: 800
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_CTX_SQL_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '1433'
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefixes: [
                '10.112.0.0/16'
                '10.114.0.0/24'
              ]
              access: 'Allow'
              priority: 900
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_ICMP'
            properties: {
              protocol: 'ICMP'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.10.0/24'
              access: 'Allow'
              priority: 1000
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_ADC'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '3003'
                '3008'
                '3009'
              ]
              sourceAddressPrefixes: [
                '10.10.10.200'
                '10.10.10.201'
                '10.10.10.205'
                '10.10.10.206'
              ]
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 1100
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_CTX_CPM'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '135'
                '139'
                '443'
                '445'
                '7750'
                '7751'
                '7771'
              ]
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefixes: [
                '10.10.9.17/32'
                '10.10.9.18/32'
              ]
              access: 'Allow'
              priority: 1200
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_CTX_VDA'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '443'
                '1494'
                '2598'
                '6901'
                '6902'
                '6905'
                '16500-16509'
                '54321-54323'
              ]
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefixes: [
                '10.10.10.0/24'
                '10.10.9.0/24'
              ]
              access: 'Allow'
              priority: 1300
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_VDA_J4'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '8080'
                '18080'
                '18081'
              ]
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefix: '10.10.8.0/24'
              access: 'Allow'
              priority: 1400
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_J4_OLD'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefixes: [
                '10.112.42.15/32'
                '10.112.42.10/32'
              ]
              access: 'Allow'
              priority: 1450
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Print'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '80'
                '443'
                '445'
                '9100'
              ]
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefix: '10.10.7.13'
              access: 'Allow'
              priority: 1500
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_Customer'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefix: '10.212.0.0/16'
              access: 'Allow'
              priority: 1600
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_PrivateEndpoint'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '443'
                '1433'
              ]
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefix: '10.10.3.0/24'
              access: 'Allow'
              priority: 1700
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
            name: 'Deny_Outbound_File'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '445'
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefix: '10.10.0.0/16'
              access: 'Deny'
              priority: 4050
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
        name: 'snet-outbound-prod-01'
        properties: {
          addressPrefix: '10.10.11.0/24'
          networkSecurityGroup: true
          routeTable: false
          natGateway: false
          privateEndpointNetworkPolicies: 'Enabled'
          delegations: 'Microsoft.Web/serverfarms'
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
              sourceAddressPrefixes: [
                '10.10.5.0/24'
                '10.10.10.0/24'
              ]
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
            name: 'Allow_Inbound_RDP_P2S'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefix: '10.15.0.0/24'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 700
              direction: 'Inbound'
            }
          }
          {
            name: 'Allow_Inbound_LB'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: 'AzureLoadBalancer'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 800
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
                '67'
                '80'
                '88'
                '123'
                '135'
                '137-139'
                '389'
                '445'
                '443'
                '464'
                '636'
                '3268-3269'
                '5722'
                '5985'
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
            name: 'Allow_Outbound_Sql_Appdeployment01'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '1433'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.3.9/32'
              access: 'Allow'
              priority: 600
              direction: 'Outbound'
            }
          }
          {
            name: 'Allow_Outbound_ICMP'
            properties: {
              protocol: 'ICMP'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.10.0/24'
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
            name: 'Deny_Outbound_File'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '445'
              sourceAddressPrefix: '10.10.10.0/24'
              destinationAddressPrefix: '10.10.0.0/16'
              access: 'Deny'
              priority: 4050
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
