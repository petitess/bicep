using '../main.bicep'

param location = 'westeurope'

param tags = {
  Application: 'Infra'
  Environment: 'Prod'
}
param kv = {
  a3careSecret: 'secrets/cert-wildcard-a3care-sefca47a4d-30e1-400a-abb4-47efab2e0ebd/'
  a3careVersion: 'e276f9ea93fc49828f7ac055aee63483'
  allowedIps: [
    '1.218.79.1/32'
    '188.150.104.230/32'
  ]
}

param maintenanceConfigurations = [
  {
    name: 'mc-dynamic-groupA'
    recurEvery: '1Month Third Monday'
    startDateTime: '2024-01-29 21:00'
    detectionTags: {
      UpdateManagement: [
        'Critical_Monthly_GroupA'
      ]
    }
  }
  {
    name: 'mc-dynamic-groupB'
    recurEvery: '1Month Third Monday'
    startDateTime: '2024-01-29 23:00'
    detectionTags: {
      UpdateManagement: [
        'Critical_Monthly_GroupB'
      ]
    }
  }
]

param storageAccounts = [
  {
    name: 'stcontactservicetest01'
    rgName: 'rg-st-infra-prod-01'
    skuName: 'Standard_LRS'
    isSftpEnabled: false
    publicAccess: 'Enabled'
    allowedIPs: []
    privateEndpoints: {
      blob: '10.10.3.23'
      file: '10.10.3.12'
    }
    shares: []
    containers: []
  }
  {
    name: 'stcontactservicetest02'
    skuName: 'Standard_LRS'
    isSftpEnabled: false
    publicAccess: 'Enabled'
    allowedIPs: []
    privateEndpoints: {
      blob: '10.10.3.13'
      file: '10.10.3.14'
    }
    shares: []
    containers: []
  }
]

param vgw = {
  vpnClientAddressPool: {
    addressPrefixes: [
      '10.15.0.0/24'
    ]
  }
  customers: [
    {
      name: 'onprem'
      tag: 'Watchguard'
      gatewayIpAddress: '81.93.155.66'
      localAddresses: [
        '10.112.0.0/16'
        '10.114.0.0/24'
        '10.113.0.0/24'
        //'10.212.0.0/16'
        // '81.89.144.0/20'
        // '82.136.128.0/18'
        // '213.189.96.0/19'
        // '10.201.110.0/24'
        // '192.168.35.0/24'
        // '192.168.30.0/24'
        // '192.168.10.0/24'
        // '194.14.187.140/32'
        // '10.212.7.0/24'
        // '10.212.1.0/24'
        // '10.212.10.0/24'
        // '10.212.11.0/24'
        // '10.212.14.0/24'
        // '10.212.50.0/24'
        // '10.212.52.0/24'
        // '10.212.54.0/24'
        // '10.212.55.0/24'
        // '192.168.250.252/30'
      ]
    }
    {
      name: 'customerabc'
      tag: 'Customer ABC'
      gatewayIpAddress: '83.140.33.1'
      localAddresses: [
        '10.212.7.0/24'
        '192.168.250.252/30'
      ]
      ipsecPolicies: [
        {
          saLifeTimeSeconds: 27000
          saDataSizeKilobytes: 0
          ipsecEncryption: 'AES256'
          ipsecIntegrity: 'SHA256'
          ikeEncryption: 'AES256'
          ikeIntegrity: 'SHA256'
          dhGroup: 'DHGroup14'
          pfsGroup: 'None'
        }
      ]
    }
    {
      name: 'customerdef'
      tag: 'Custoemr DEF'
      gatewayIpAddress: '213.244.245.1'
      localAddresses: [
        '10.212.4.0/24'
      ]
      ipsecPolicies: [
        {
          saLifeTimeSeconds: 27000
          saDataSizeKilobytes: 0
          ipsecEncryption: 'GCMAES128'
          ipsecIntegrity: 'GCMAES128'
          ikeEncryption: 'GCMAES128'
          ikeIntegrity: 'SHA256'
          dhGroup: 'DHGroup14'
          pfsGroup: 'PFS2048'
        }
      ]
    }
  ]
}

param webtests = [
  {
    name: 'primapraktiken-webtidbok.comp.se'
    url: 'https://primapraktiken-webtidbok.comp.se'
    enabled: false
    description: 'vmwtbprod01'
  }
  {
    name: 'kusten.comp.se'
    url: 'https://kusten.comp.se/login'
    enabled: false
    description: 'vmwebprod01'
  }
  {
    name: 'certificate.comp.se'
    url: 'https://certificate.comp.se'
    enabled: false
    description: 'vmcaprod01'
  }
]

param apps = [
  {
    name: 'app-abcdef-prod-01'
    resourceGroup: 'rg-app-abcdef-prod-01'
    alertsEnabled: false
    appServicePlanName: 'asp-infra-prod-01'
    authEnabled: true
    privateEndpoints: {
      sites: '10.10.3.22'
      'sites-stage': '10.10.3.32'
    }
    appSettings: [
      {
        name: 'MY_VAR'
        value: 'ABC'
      }
    ]
    keyVault: {
      ipPep: '10.10.3.30'
    }
    slot: {
      appSettings: [
        {
          name: 'MY_VAR'
          value: 'ABC'
        }
      ]
    }
    sqlServer: {
      dbCount: 2
      ipPep: '10.10.3.33'
      publicNetworkAccess: 'Disabled'
      sqlDtu: 10
      sqlTier: 'Standard'
    }
  }
  {
    name: 'app-abcdef-prod-02'
    resourceGroup: 'rg-app-abcdef-prod-02'
    alertsEnabled: false
    appServicePlanName: 'asp-infra-prod-01'
    authEnabled: true
    privateEndpoints: {
      sites: '10.10.3.35'
      'sites-stage': '10.10.3.36'
    }
    appSettings: [
      {
        name: 'MY_VAR'
        value: 'ABC'
      }
    ]
    keyVault: {
      ipPep: '10.10.3.37'
    }
    slot: {
      appSettings: [
        {
          name: 'MY_VAR'
          value: 'ABC'
        }
      ]
    }
    sqlServer: {
      dbCount: 2
      ipPep: '10.10.3.38'
      publicNetworkAccess: 'Disabled'
      sqlDtu: 10
      sqlTier: 'Standard'
    }
  }
  {
    name: 'app-abcdef-prod-03'
    resourceGroup: 'rg-app-abcdef-prod-03'
    alertsEnabled: false
    appServicePlanName: 'asp-infra-prod-01'
    authEnabled: false
    privateEndpoints: {
      sites: '10.10.3.45'
      'sites-stage': '10.10.3.46'
    }
    appSettings: [
      {
        name: 'MY_VAR'
        value: 'ABC'
      }
    ]
    keyVault: {
      ipPep: '10.10.3.47'
    }
    slot: {
      appSettings: [
        {
          name: 'MY_VAR'
          value: 'ABC'
        }
      ]
    }
    sqlServer: {
      dbCount: 2
      ipPep: '10.10.3.48'
      publicNetworkAccess: 'Disabled'
      sqlDtu: 10
      sqlTier: 'Standard'
    }
  }
]

param vnet = {
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
      name: 'snet-pep'
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
      name: 'snet-core'
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
              '10.112.0.0/17'
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
      name: 'snet-mgmt'
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
          name: 'Allow_Inbound_Ctx_Services_VDA'
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
            ]
            access: 'Allow'
            priority: 1200
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
          name: 'Allow_Outbound_Ctx_Services'
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
            ]
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 900
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
      name: 'snet-sql'
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
          name: 'Allow_Inbound_SQL_CTX'
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
              '10.112.0.0/17'
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
      name: 'snet-app'
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
      name: 'snet-web'
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
          name: 'Allow_Inbound_LoginCtx_OLD'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRanges: [
              '18080'
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
            destinationPortRanges: [
              '443'
              '9082'
              '9086'
            ]
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
              '8080'
              '8082'
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
            ]
            sourceAddressPrefix: '*'
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
      name: 'snet-ctx'
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
          name: 'Allow_Inbound_Ctx_Services'
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
          name: 'Allow_Inbound_Ctx_Services_VDA'
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
          name: 'Allow_Inbound_CPM'
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
            destinationAddressPrefix: '10.10.5.0/24'
            access: 'Allow'
            priority: 600
            direction: 'Outbound'
          }
        }
        {
          name: 'Allow_Outbound_Ctx_Services'
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
          name: 'Allow_Outbound_SQL_PVS'
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
          name: 'Allow_Outbound_Ctx_Services_VDA'
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
          name: 'Allow_Outbound_CPM_MGMT'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRanges: [
              '135'
              '139'
              '445'
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
      name: 'snet-vda'
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
          name: 'Allow_Inbound_Ctx_Services_VDA'
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
              '54321-54323'
              '16500-16509'
            ]
            sourceAddressPrefix: '10.10.9.0/24'
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
            destinationPortRange: '443'
            sourceAddressPrefix: '10.10.0.0/16'
            destinationAddressPrefixes: [
              '10.10.10.200'
              '10.10.10.201'
            ]
            access: 'Allow'
            priority: 900
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow_Inbound_CPM_MGMT'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRanges: [
              '135'
              '139'
              '445'
            ]
            sourceAddressPrefix: '10.10.9.0/24'
            destinationAddressPrefix: '10.10.10.0/24'
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
            destinationAddressPrefix: '10.10.5.0/24'
            access: 'Allow'
            priority: 600
            direction: 'Outbound'
          }
        }
        {
          name: 'Allow_Outbound_Ctx_Services'
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
            ]
            destinationAddressPrefix: '*'
            access: 'Deny'
            priority: 1100
            direction: 'Outbound'
          }
        }
        {
          name: 'Allow_Outbound_CPM'
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
      name: 'snet-asp'
      properties: {
        addressPrefix: '10.10.11.0/24'
        networkSecurityGroup: true
        routeTable: false
        natGateway: false
        privateEndpointNetworkPolicies: 'Enabled'
        delegation: 'Microsoft.Web/serverFarms'
      }
      routeTable: {
        properties: {}
      }
      securityRules: []
    }
  ]
}

param vm = [
  // {
  //   name: 'vmmgmtprod01'
  //   rgName: 'rg-vmmgmtprod01'
  //   availabilitySetName: ''
  //   installCompCert: false
  //   tags: {
  //     Application: 'Management'
  //     Service: 'Management'
  //     UpdateManagement: 'Critical_Monthly_GroupA'
  //     Autoshutdown: 'No'
  //   }
  //   vmSize: 'Standard_E2bds_v5'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.5.11'
  //       primary: true
  //       subnet: 'snet-mgmt'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmmtdprod01'
  //   rgName: 'rg-vmmtdprod01'
  //   availabilitySetName: ''
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'Citrix'
  //     Service: 'Master Target Device'
  //     UpdateManagement: 'NotSupported'
  //     Autoshutdown: 'No'
  //     Status: 'Stopped'
  //   }
  //   vmSize: 'Standard_D8ads_v5'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsdesktop'
  //     offer: 'windows-11'
  //     sku: 'win11-22h2-avd'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Dynamic'
  //       privateIPAddress: ''
  //       primary: true
  //       subnet: 'snet-vda'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: true
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: false
  // }
  // {
  //   name: 'vmsqlprod01'
  //   rgName: 'rg-vmsqlprod01'
  //   availabilitySetName: ''
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'SQL'
  //     Service: 'PVS, Net iD, Medrave'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //   }
  //   vmSize: 'Standard_E2bds_v5'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftsqlserver'
  //     offer: 'sql2019-ws2022'
  //     sku: 'standard'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: [
  //     {
  //       name: 'dataDisk-0'
  //       storageAccountType: 'Premium_LRS'
  //       createOption: 'Empty'
  //       caching: 'ReadWrite'
  //       lun: 0
  //       diskSizeGB: 300
  //     }
  //     {
  //       name: 'dataDisk-1'
  //       storageAccountType: 'Premium_LRS'
  //       createOption: 'Empty'
  //       caching: 'ReadWrite'
  //       lun: 1
  //       diskSizeGB: 300
  //     }
  //   ]
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.6.11'
  //       primary: true
  //       subnet: 'snet-sql'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: true
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  {
    name: 'vmsqlprod02'
    rgName: 'rg-vmsqlprod02'
    availabilitySetName: ''
    installA3CareCert: false
    tags: {
      Application: 'SQL'
      Service: 'CGM J4, CGM J4 Demo'
      UpdateManagement: 'Critical_Monthly_GroupA'
    }
    vmSize: 'Standard_E8ds_v5'
    plan: {}
    imageReference: {
      publisher: 'microsoftsqlserver'
      offer: 'sql2019-ws2022'
      sku: 'standard'
      version: 'latest'
    }
    osDiskSizeGB: 128
    dataDisks: [
      {
        name: 'dataDisk-3'
        storageAccountType: 'Premium_LRS'
        createOption: 'Empty'
        caching: 'None'
        lun: 3
        diskLetter: 'E'
        diskSizeGB: 4100
        tier: 'P60'
      }
      {
        name: 'dataDisk-4'
        storageAccountType: 'Premium_LRS'
        createOption: 'Empty'
        caching: 'ReadWrite'
        lun: 4
        diskLetter: 'F'
        diskSizeGB: 1000
      }
      {
        name: 'dataDisk-5'
        storageAccountType: 'Premium_LRS'
        createOption: 'Empty'
        caching: 'ReadWrite'
        lun: 5
        diskLetter: 'G'
        diskSizeGB: 3000
      }
    ]
    networkInterfaces: [
      {
        privateIPAllocationMethod: 'Static'
        privateIPAddress: '10.10.6.12'
        primary: true
        subnet: 'snet-sql'
        publicIPAddress: false
        enableIPForwarding: false
        enableAcceleratedNetworking: true
      }
    ]
    backup: {
      enabled: false
    }
    monitor: {
      alert: false
      enabled: false
    }
    extensions: true
  }
  {
    name: 'vmwebprod01'

    availabilitySetName: ''
    installA3CareCert: false
    tags: {
      Application: 'CGM J4'
      Service: 'CGM J4 Demo'
      UpdateManagement: 'Critical_Monthly_GroupB'
      Autoshutdown: 'No'
      Status: 'Stopped'
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
        privateIPAddress: '10.10.8.11'
        primary: true
        subnet: 'snet-web'
        publicIPAddress: true
        enableIPForwarding: false
        enableAcceleratedNetworking: false
      }
    ]
    backup: {
      enabled: false
    }
    monitor: {
      alert: false
      enabled: false
    }
    extensions: true
  }
  // {
  //   name: 'vmwebprod03'
  //   rgName: 'rg-vmwebprod03'
  //   availabilitySetName: ''
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'CGM J4'
  //     Service: 'CGM J4'
  //     Customer: 'Centrumpraktiken'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //     Restart: 'GroupA'
  //   }
  //   vmSize: 'Standard_D2ads_v5'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.8.17'
  //       primary: true
  //       subnet: 'snet-web'
  //       publicIPAddress: true
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: true
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmwebprod04'
  //   rgName: 'rg-vmwebprod04'
  //   availabilitySetName: ''
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'CGM J4'
  //     Service: 'CGM J4'
  //     Customer: 'Maria Alberts VC'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //     Restart: 'GroupA'
  //   }
  //   vmSize: 'Standard_D2ads_v5'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.8.19'
  //       primary: true
  //       subnet: 'snet-web'
  //       publicIPAddress: true
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: true
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmwebprod06'
  //   rgName: 'rg-vmwebprod06'
  //   availabilitySetName: ''
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'CGM J4'
  //     Service: 'CGM J4'
  //     Customer: 'Improve Rehab'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //     Restart: 'GroupB'
  //   }
  //   vmSize: 'Standard_B2s'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.8.18'
  //       primary: true
  //       subnet: 'snet-web'
  //       publicIPAddress: true
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmwebprod07'
  //   rgName: 'rg-vmwebprod07'
  //   availabilitySetName: ''
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'CGM J4'
  //     Service: 'CGM J4'
  //     Customer: 'Nordstan'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //     Restart: 'GroupB'
  //   }
  //   vmSize: 'Standard_D2ads_v5'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.8.20'
  //       primary: true
  //       subnet: 'snet-web'
  //       publicIPAddress: true
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: true
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmwebprod09'
  //   rgName: 'rg-vmwebprod09'
  //   availabilitySetName: ''
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'CGM J4'
  //     Service: 'CGM J4'
  //     Customer: 'Rävlanda'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //     Restart: 'GroupB'
  //   }
  //   vmSize: 'Standard_D2ads_v5'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.8.21'
  //       primary: true
  //       subnet: 'snet-web'
  //       publicIPAddress: true
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: true
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmwebprod15'
  //   rgName: 'rg-vmwebprod15'
  //   availabilitySetName: ''
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'CGM J4'
  //     Service: 'CGM J4'
  //     Customer: 'Psoriasisförbundet'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //     Restart: 'GroupB'
  //   }
  //   vmSize: 'Standard_B2s'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.8.22'
  //       primary: true
  //       subnet: 'snet-web'
  //       publicIPAddress: true
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmwebprod16'
  //   rgName: 'rg-vmwebprod16'
  //   availabilitySetName: ''
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'CGM J4'
  //     Service: 'CGM J4'
  //     Customer: 'Vår Vårdcentral'
  //     UpdateManagement: 'Critical_Monthly_GroupA'
  //     Restart: 'GroupB'
  //   }
  //   vmSize: 'Standard_B2s'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.8.25'
  //       primary: true
  //       subnet: 'snet-web'
  //       publicIPAddress: true
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmwtbprod01'
  //   rgName: 'rg-vmwtbprod01'
  //   availabilitySetName: ''
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'CGM J4'
  //     Service: 'Webbtidbok'
  //     Customer: 'Kusten'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //     Autoshutdown: 'No'
  //   }
  //   vmSize: 'Standard_B2ms'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.8.16'
  //       primary: true
  //       subnet: 'snet-web'
  //       publicIPAddress: true
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmmonprod01'
  //   rgName: 'rg-vmmonprod01'
  //   availabilitySetName: ''
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'Monitor'
  //     Service: 'Zabbix'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //   }
  //   vmSize: 'Standard_B2s'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'canonical'
  //     offer: '0001-com-ubuntu-server-focal'
  //     sku: '20_04-lts'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.7.11'
  //       primary: true
  //       subnet: 'snet-app'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: false
  // }
  // {
  //   name: 'vmfileprod01'
  //   rgName: 'rg-vmfileprod01'
  //   availabilitySetName: ''
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'File'
  //     Service: 'File, Home directory'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //     Autoshutdown: 'No'
  //   }
  //   vmSize: 'Standard_D2ads_v5'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: [
  //     {
  //       name: 'dataDisk-0'
  //       storageAccountType: 'Premium_LRS'
  //       createOption: 'Empty'
  //       caching: 'ReadWrite'
  //       lun: 0
  //       diskSizeGB: 750
  //     }
  //   ]
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.7.12'
  //       primary: true
  //       subnet: 'snet-app'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: true
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  {
    name: 'vmprintprod01'
    rgName: 'rg-vmprintprod01'
    availabilitySetName: ''
    installA3CareCert: false
    tags: {
      Application: 'Print'
      Service: 'Print'
      UpdateManagement: 'Critical_Monthly_GroupA'
      Autoshutdown: 'No'
    }
    vmSize: 'Standard_B2s'
    plan: {}
    imageReference: {
      publisher: 'microsoftwindowsserver'
      offer: 'windowsserver'
      sku: '2022-datacenter-smalldisk'
      version: 'latest'
    }
    osDiskSizeGB: 60
    dataDisks: []
    networkInterfaces: [
      {
        privateIPAllocationMethod: 'Static'
        privateIPAddress: '10.10.7.13'
        primary: true
        subnet: 'snet-app'
        publicIPAddress: false
        enableIPForwarding: false
        enableAcceleratedNetworking: false
      }
    ]
    backup: {
      enabled: false
    }
    monitor: {
      alert: false
      enabled: false
    }
    extensions: true
  }
  // {
  //   name: 'vmcaprod01'
  //   rgName: 'rg-vmcaprod01'
  //   availabilitySetName: ''
  //   computerName: 'a3care-se-ca01'
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'Core'
  //     Service: 'Certificate Services'
  //     UpdateManagement: 'Critical_Monthly_GroupA'
  //   }
  //   vmSize: 'Standard_B2s'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter-smalldisk'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 60
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.4.12'
  //       primary: true
  //       subnet: 'snet-core'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmnipprod01'
  //   rgName: 'rg-vmnipprod01'
  //   availabilitySetName: ''
  //   installCompCert: false
  //   tags: {
  //     Application: 'Net iD'
  //     Service: 'Portal server'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //   }
  //   vmSize: 'Standard_B2s'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.8.12'
  //       primary: true
  //       subnet: 'snet-web'
  //       publicIPAddress: true
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmniaprod01'
  //   rgName: 'rg-vmniaprod01'
  //   availabilitySetName: ''
  //   installCompCert: false
  //   tags: {
  //     Application: 'Net iD'
  //     Service: 'Access server'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //   }
  //   vmSize: 'Standard_B2s'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.8.13'
  //       primary: true
  //       subnet: 'snet-web'
  //       publicIPAddress: true
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmlicprod01'
  //   rgName: 'rg-vmlicprod01'
  //   availabilitySetName: ''
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'Citrix'
  //     Service: 'License'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //   }
  //   vmSize: 'Standard_B2s'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.9.20'
  //       primary: true
  //       subnet: 'snet-ctx'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmfasprod01'
  //   rgName: 'rg-vmfasprod01'
  //   availabilitySetName: ''
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'Citrix'
  //     Service: 'Federated Authentication Service'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //   }
  //   vmSize: 'Standard_B2s'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.9.21'
  //       primary: true
  //       subnet: 'snet-ctx'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmraveprod01'
  //   rgName: 'rg-vmraveprod01'
  //   availabilitySetName: ''
  //   installCompCert: false
  //   tags: {
  //     Application: 'Medrave'
  //     Service: 'Statistikprogram'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //   }
  //   vmSize: 'Standard_B2ms'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: [
  //     {
  //       name: 'dataDisk-0'
  //       storageAccountType: 'Premium_LRS'
  //       createOption: 'Empty'
  //       caching: 'None'
  //       lun: 0
  //       diskSizeGB: 50
  //     }
  //   ]
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.8.15'
  //       primary: true
  //       subnet: 'snet-web'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  {
    name: 'vmctxprod01'
    rgName: 'rg-vmctxprod01'
    availabilitySetName: 'avail-vmctxprod01'
    installCompCert: false
    tags: {
      Application: 'Citrix'
      Service: 'Citrix Cloud Connector'
      UpdateManagement: 'Critical_Monthly_GroupA'
    }
    vmSize: 'Standard_B2ms'
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
        privateIPAddress: '10.10.9.11'
        primary: true
        subnet: 'snet-ctx'
        publicIPAddress: false
        enableIPForwarding: false
        enableAcceleratedNetworking: false
      }
    ]
    backup: {
      enabled: false
    }
    monitor: {
      alert: false
      enabled: false
    }
    extensions: true
  }
  // {
  //   name: 'vmctxprod02'
  //   rgname: 'rg-vmctxprod01'
  //   availabilitySetName: 'avail-vmctxprod01'
  //   installCompCert: false
  //   tags: {
  //     Application: 'Citrix'
  //     Service: 'Citrix Cloud Connector'
  //     UpdateManagement: 'Critical_Monthly_GroupA'
  //   }
  //   vmSize: 'Standard_B2ms'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.9.12'
  //       primary: true
  //       subnet: 'snet-ctx'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  {
    name: 'vmdcprod01'
    rgname: 'rg-vmdcprod01'
    availabilitySetName: 'avail-vmdcprod01'
    installCompCert: false
    tags: {
      Application: 'Core'
      Service: 'ActiveDirectory'
      UpdateManagement: 'Critical_Monthly_GroupA'
    }
    vmSize: 'Standard_B2ms'
    plan: {}
    imageReference: {
      publisher: 'microsoftwindowsserver'
      offer: 'windowsserver'
      sku: '2022-datacenter'
      version: 'latest'
    }
    osDiskSizeGB: 128
    dataDisks: [
      {
        name: 'dataDisk-0'
        storageAccountType: 'Premium_LRS'
        createOption: 'Empty'
        caching: 'None'
        lun: 0
        diskSizeGB: 16
      }
    ]
    networkInterfaces: [
      {
        privateIPAllocationMethod: 'Static'
        privateIPAddress: '10.10.4.11'
        primary: true
        subnet: 'snet-core'
        publicIPAddress: false
        enableIPForwarding: false
        enableAcceleratedNetworking: false
      }
    ]
    backup: {
      enabled: false
    }
    monitor: {
      alert: false
      enabled: false
    }
    extensions: true
  }
  // {
  //   name: 'vmdcprod02'
  //   rgname: 'rg-vmdcprod01'
  //   availabilitySetName: 'avail-vmdcprod01'
  //   installCompCert: false
  //   tags: {
  //     Application: 'Core'
  //     Service: 'ActiveDirectory'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //   }
  //   vmSize: 'Standard_B2ms'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: [
  //     {
  //       name: 'dataDisk-0'
  //       storageAccountType: 'Premium_LRS'
  //       createOption: 'Empty'
  //       caching: 'None'
  //       lun: 0
  //       diskSizeGB: 16
  //     }
  //   ]
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.4.13'
  //       primary: true
  //       subnet: 'snet-core'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  {
    name: 'vmpvsprod01'
    rgname: 'rg-vmpvsprod01'
    availabilitySetName: 'avail-vmpvsprod01'
    installA3CareCert: false
    tags: {
      Application: 'Citrix'
      Service: 'Citrix Provisioning Services'
      UpdateManagement: 'Critical_Monthly_GroupA'
    }
    vmSize: 'Standard_E2bds_v5'
    plan: {}
    imageReference: {
      publisher: 'microsoftwindowsserver'
      offer: 'windowsserver'
      sku: '2022-datacenter'
      version: 'latest'
    }
    osDiskSizeGB: 128
    dataDisks: [
      {
        name: 'dataDisk-0'
        storageAccountType: 'Premium_LRS'
        createOption: 'Empty'
        caching: 'ReadWrite'
        lun: 0
        diskSizeGB: 500
      }
    ]
    networkInterfaces: [
      {
        privateIPAllocationMethod: 'Static'
        privateIPAddress: '10.10.9.16'
        primary: true
        subnet: 'snet-ctx'
        publicIPAddress: false
        enableIPForwarding: false
        enableAcceleratedNetworking: true
      }
    ]
    backup: {
      enabled: false
    }
    monitor: {
      alert: false
      enabled: false
    }
    extensions: true
  }
  // {
  //   name: 'vmpvsprod02'
  //   rgname: 'rg-vmpvsprod01'
  //   availabilitySetName: 'avail-vmpvsprod01'
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'Citrix'
  //     Service: 'Citrix Provisioning Services'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //   }
  //   vmSize: 'Standard_E2bds_v5'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: [
  //     {
  //       name: 'dataDisk-0'
  //       storageAccountType: 'Premium_LRS'
  //       createOption: 'Empty'
  //       caching: 'ReadWrite'
  //       lun: 0
  //       diskSizeGB: 500
  //     }
  //   ]
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.9.15'
  //       primary: true
  //       subnet: 'snet-ctx'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: true
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmsfprod01'
  //   rgname: 'rg-vmsfprod01'
  //   availabilitySetName: 'avail-vmsfprod01'
  //   installCompCert: false
  //   tags: {
  //     Application: 'Citrix'
  //     Service: 'StoreFront'
  //     UpdateManagement: 'Critical_Monthly_GroupA'
  //   }
  //   vmSize: 'Standard_B2ms'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.9.13'
  //       primary: true
  //       subnet: 'snet-ctx'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmsfprod02'
  //   rgname: 'rg-vmsfprod01'
  //   availabilitySetName: 'avail-vmsfprod01'
  //   installCompCert: false
  //   tags: {
  //     Application: 'Citrix'
  //     Service: 'StoreFront'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //   }
  //   vmSize: 'Standard_B2ms'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.9.14'
  //       primary: true
  //       subnet: 'snet-ctx'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmcpmprod01'
  //   rgname: 'rg-vmcpmprod01'
  //   availabilitySetName: 'avail-vmcpmprod01'
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'Citrix'
  //     Service: 'Citrix Profile Management/Ivanti'
  //     UpdateManagement: 'Critical_Monthly_GroupA'
  //   }
  //   vmSize: 'Standard_D2ads_v5'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.9.17'
  //       primary: true
  //       subnet: 'snet-ctx'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: true
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
  // {
  //   name: 'vmcpmprod02'
  //   rgname: 'rg-vmcpmprod01'
  //   availabilitySetName: 'avail-vmcpmprod01'
  //   installA3CareCert: false
  //   tags: {
  //     Application: 'Citrix'
  //     Service: 'Citrix Profile Management/Ivanti'
  //     UpdateManagement: 'Critical_Monthly_GroupB'
  //   }
  //   vmSize: 'Standard_D2ads_v5'
  //   plan: {}
  //   imageReference: {
  //     publisher: 'microsoftwindowsserver'
  //     offer: 'windowsserver'
  //     sku: '2022-datacenter'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 128
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.9.18'
  //       primary: true
  //       subnet: 'snet-ctx'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: true
  //     }
  //   ]
  //   backup: {
  //     enabled: false
  //   }
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  //   extensions: true
  // }
]

param vmAdc = [
  {
    name: 'vmadcprod01'
    rgName: 'rg-vmadcprod01'
    availabilitySetName: 'avail-vmadcprod01'
    tags: {
      Application: 'Citrix'
      Service: 'Application Delivery Controller'
      UpdateManagement: 'NotSupported'
    }
    vmSize: 'Standard_F8s_v2'
    plan: {
      publisher: 'citrix'
      product: 'netscalervpx-131'
      name: 'netscalerbyol'
    }
    imageReference: {
      publisher: 'citrix'
      offer: 'netscalervpx-131'
      sku: 'netscalerbyol'
      version: 'latest'
    }
    osDiskSizeGB: 64
    dataDisks: []
    networkInterfaces: [
      {
        privateIPAllocationMethod: 'Static'
        privateIPAddress: '10.10.5.205'
        primary: true
        subnet: 'snet-mgmt'
        publicIPAddress: false
        enableIPForwarding: false
        enableAcceleratedNetworking: false
        externalLoadBalancer: false
        internalLoadBalancer: false
      }
      {
        privateIPAllocationMethod: 'Static'
        privateIPAddress: '10.10.10.205'
        primary: false
        subnet: 'snet-vda'
        publicIPAddress: false
        enableIPForwarding: false
        enableAcceleratedNetworking: true
        externalLoadBalancer: false
        internalLoadBalancer: true
      }
      {
        privateIPAllocationMethod: 'Static'
        privateIPAddress: '10.10.8.205'
        primary: false
        subnet: 'snet-web'
        publicIPAddress: false
        enableIPForwarding: false
        enableAcceleratedNetworking: true
        externalLoadBalancer: true
        internalLoadBalancer: false
      }
    ]
    monitor: {
      alert: false
      enabled: false
    }
  }
  // {
  //   name: 'vmadcprod02'
  //   rgname: 'rg-vmadcprod01'
  //   availabilitySetName: 'avail-vmadcprod01'

  //   tags: {
  //     Application: 'Citrix'
  //     Service: 'Application Delivery Controller'
  //     UpdateManagement: 'NotSupported'
  //   }
  //   vmSize: 'Standard_F8s_v2'
  //   plan: {
  //     publisher: 'citrix'
  //     product: 'netscalervpx-131'
  //     name: 'netscalerbyol'
  //   }
  //   imageReference: {
  //     publisher: 'citrix'
  //     offer: 'netscalervpx-131'
  //     sku: 'netscalerbyol'
  //     version: 'latest'
  //   }
  //   osDiskSizeGB: 64
  //   dataDisks: []
  //   networkInterfaces: [
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.5.206'
  //       primary: true
  //       subnet: 'snet-mgmt'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: false
  //       externalLoadBalancer: false
  //       internalLoadBalancer: false
  //     }
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.10.206'
  //       primary: false
  //       subnet: 'snet-vda'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: true
  //       externalLoadBalancer: false
  //       internalLoadBalancer: true
  //     }
  //     {
  //       privateIPAllocationMethod: 'Static'
  //       privateIPAddress: '10.10.8.206'
  //       primary: false
  //       subnet: 'snet-web'
  //       publicIPAddress: false
  //       enableIPForwarding: false
  //       enableAcceleratedNetworking: true
  //       externalLoadBalancer: true
  //       internalLoadBalancer: false
  //     }
  //   ]
  //   monitor: {
  //     alert: false
  //     enabled: false
  //   }
  // }
]
