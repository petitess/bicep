using 'main.bicep'

param env = 'test'
param param = {
  location: 'SwedenCentral'
  locationAlt: 'WestEurope'
  tags: {
    Application: 'Infra'
    Environment: 'Test'
  }
  vgw: {
    deploy: false
    vpnClientAddressPool: {
      addressPrefixes: [
        '10.110.0.0/16'
      ]
    }
    vpnClientRootCertificates: [
      {
        name: 'MY-P2SRootCert'
        properties: {
          publicCertData: 'MIIDJzCCAg+gAwIBAgIQXAFXBKOCkIBM6MSJZ7icUDANBgkqhkiG9w0BAQsFADAZMRcwFQYDVQQDDA53d3cuZG9tYWluLmNvbTAeFw0yMjA3MTQxNDI5MTdaFw0yMzA3MTQxNDQ5MTdaMBkxFzAVBgNVBAMMDnd3dy5kb21haW4uY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnClXeAhByF3rKB03zlargk/FIa/i0b4Pvubclw9eD3C/NQ0F8ypPFpVknL3z8LxODAbiG0Lk3NZnzZcnzD8YP7K9kOLz9SNlCsOd/bJxShZS+8eF+giCnEY+KqRhJ/P8PUP/dZnvCVI8GTc4piLMKdkwvXqpez2CPBCmOLIvhcGbOUIg2M7x/aHxw9kklzzk1nR6Wu3uD3d3OZBGd5gh+fpeVxHivu4A4SEIfCV4naSV6zGrOvIGsiCgj3MzxW/aUs17w1TC+unLtwkYr43oED4uNIe5Wdzya99Jw7mfV6dkmyrI7c7EU9Ds3P/Yq5oPNSBhB6BuJP+ZTSb9mKosgQIDAQABo2swaTAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMBMBkGA1UdEQQSMBCCDnd3dy5kb21haW4uY29tMB0GA1UdDgQWBBQc1CZc3GdZZCFttT46aWAVCCMJrzANBgkqhkiG9w0BAQsFAAOCAQEAbgHoSpRB5xEMIHF/vl5ApHE5LwA05fljvAD24rGsIUN/JnZ1bhda/Qgwv8AzfTi9EvrYArBtnLWXyGT8Mb7vaneS/iId9X0bDyHi4Ldh4SzmSkPZX0I0epVPyx0A6aCZjVboBrs5sJRl6lj2UYstmcV4q4+Cy53Rt17hcT0IXVSj4jSxp4qrh3ymK5GAVaEizua6D7JCt2wxeK68lfwYtv2+ERRiC4tdEDlGGkGmO7uZCMU+0vMLZhDMQFscm75Ofw4bFUZaRPBW5JNK4RKPkV0JyJK0cOEhT49DXtxrMDW7/9tVLL50cuK1QsncxXTqKA27mWfI9Zcd/dmls9aocA=='
        }
      }
    ]
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: '10.15.255.254'
      peerWeight: 0
    }
    lgw: {
      localNetworkAddressSpace: {
        addressPrefixes: [
          '10.112.0.0/16'
          '10.113.0.0/16'
        ]
      }
      gatewayIpAddress: '12.34.56.78'
    }
    con: {
      name: 'con-azure-to-on-prem'
      sharedKey: '4*!dnxxxoqhPa#5@'
    }
  }
  st: [
    {
      name: 'stinfratestsc01'
      sku: 'Standard_LRS'
      kind: 'StorageV2'
      containersCount: 2
      publicNetworkAccess: 'Disabled'
      shares: [
        {
          name: 'fileshare01'
          properties: {
            accessTier: 'Hot'
            shareQuota: 5120
            enabledProtocols: 'SMB'
          }
        }
      ]
    }
  ]
  rsv: {
    sku: {
      name: 'RS0'
      tier: 'Standard'
    }
    scheduleRunTimes: [
      '22:30:00'
    ]
    retentionDays: 30
    timeZone: 'UTC'
  }
  noAvailabilitySets: [
    'vmabctest01'
    'vmlinuxtest01'
  ]
  availabilitySets: [
    'vmdctest01'
  ]
  vnet: {
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
        name: 'snet-pe-prod-01'
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
                '10.15.0.0/24'
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
            name: 'Allow_Inbound_RDP_P2S'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefix: '10.110.0.0/16'
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
              sourceAddressPrefix: '10.110.0.0/16'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 900
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
            name: 'Allow_Inbound_RDP_P2S'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '3389'
              sourceAddressPrefix: '10.110.0.0/16'
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
            name: 'Allow_Outbound_File'
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
        name: 'snet-web-prod-01'
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
              destinationPortRanges: [
                '443'
                '8080'
              ]
              sourceAddressPrefix: 'Internet'
              destinationAddressPrefix: '10.10.8.0/24'
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
            name: 'Allow_Outbound_File'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '445'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.5.0/24'
              access: 'Allow'
              priority: 1100
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
  vms: [
    {
      name: 'vmdctest01'
      rgName: 'rg-vmdctest01'
      availName: 'avail-vmdctest01'
      tags: {
        Application: 'Core'
        Service: 'ActiveDirectory'
        UpdateManagement: 'Critical_Monthly_GroupA'
      }
      vmSize: 'Standard_B2s'
      plan: {}
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDiskSizeGB: 128
      dataDisks: []
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.10.4.15'
          primary: true
          subnet: 'snet-core-prod-01'
          publicIPAddress: false
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
      backup: {
        enabled: false
        weekly: false
      }
      monitor: {
        alert: true
        enabled: true
      }
      UpdateMgmtV2: true
      WindowsOS: true
      LinuxOS: false
    }
    {
      name: 'vmdctest02'
      rgName: 'rg-vmdctest01'
      availName: 'avail-vmdctest01'
      tags: {
        Application: 'Core'
        Service: 'ActiveDirectory'
        UpdateManagement: 'Critical_Monthly_GroupB'
      }
      vmSize: 'Standard_B2s'
      plan: {}
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDiskSizeGB: 128
      dataDisks: []
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.10.4.16'
          primary: true
          subnet: 'snet-core-prod-01'
          publicIPAddress: false
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
      backup: {
        enabled: false
        weekly: false
      }
      monitor: {
        alert: true
        enabled: true
      }
      UpdateMgmtV2: true
      WindowsOS: true
      LinuxOS: false
    }
    {
      name: 'vmabctest01'
      rgName: 'rg-vmabctest01'
      availName: ''
      tags: {
        Application: 'Core'
        Service: 'ActiveDirectory'
        UpdateManagement: 'Critical_Monthly_GroupA'
        AutoShutdown: 'GruppA'
      }
      vmSize: 'Standard_B2s'
      plan: {}
      imageReference: {
        publisher: 'microsoftwindowsdesktop'
        offer: 'windows-11'
        sku: 'win11-22h2-ent'
        version: 'latest'
      }
      osDiskSizeGB: 128
      dataDisks: [
        {
          name: 'dataDisk-0'
          storageAccountType: 'Premium_LRS'
          createOption: 'Empty'
          lun: 0
          diskSizeGB: 10
        }
      ]
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.10.4.11'
          primary: true
          subnet: 'snet-core-prod-01'
          publicIPAddress: false
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
      backup: {
        enabled: false
        weekly: false
      }
      monitor: {
        alert: true
        enabled: true
      }
      UpdateMgmtV2: false
      WindowsOS: true
      LinuxOS: false
    }
    {
      name: 'vmlinuxtest01'
      rgName: 'rg-vmlinuxtest01'
      availName: ''
      tags: {
        Application: 'Core'
        Service: 'ActiveDirectory'
        UpdateManagement: 'Critical_Monthly_GroupB'
        AutoShutdown: 'GruppB'
      }
      vmSize: 'Standard_B1ms'
      plan: {}
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDiskSizeGB: 50
      dataDisks: []
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.10.7.11'
          primary: true
          subnet: 'snet-app-prod-01'
          publicIPAddress: false
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
      backup: {
        enabled: false
        weekly: false
      }
      monitor: {
        alert: true
        enabled: true
      }
      UpdateMgmtV2: false
      WindowsOS: false
      LinuxOS: true
    }
  ]
}
