using '../main.bicep'

param env = 'dev'
param tags = {
  product: 'infra'
}
var myIP = '1.1.1.1'
var addressPrefixes = ['10.10.0.0/20']

var subnets = {
  GatewaySubnet: cidrSubnet(addressPrefixes[0], 26, 0)
  AzureFirewallSubnet: cidrSubnet(addressPrefixes[0], 26, 1)
  AzureBastionSubnet: cidrSubnet(addressPrefixes[0], 26, 2)
  'snet-mgmt': cidrSubnet(addressPrefixes[0], 26, 3)
  'snet-app': cidrSubnet(addressPrefixes[0], 26, 4)
  'snet-pep': cidrSubnet(addressPrefixes[0], 26, 5)
}

param keyVaults = [
  {
    name: 'kvdesdev01'
    rgName: 'rg-des-dev-01'
    publicNetworkAccess: 'Allow'
    allowIps: []
    enablePurgeProtection: true
    ipAddress: '10.10.1.70'
  }
]

param vnet = {
  addressPrefixes: addressPrefixes
  subnets: [
    {
      name: 'GatewaySubnet'
      addressPrefix: subnets.GatewaySubnet
    }
    {
      name: 'AzureFirewallSubnet'
      addressPrefix: subnets.AzureFirewallSubnet
    }
    {
      name: 'AzureBastionSubnet'
      addressPrefix: subnets.AzureBastionSubnet
    }
    {
      name: 'snet-mgmt'
      addressPrefix: subnets['snet-mgmt']
      rules: [
        {
          name: 'Allow_Inbound_RDP'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '3389'
            sourceAddressPrefix: 'Internet'
            destinationAddressPrefix: '*'
            access: 'Allow'
            priority: 200
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow_Inbound_subnet'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: '10.0.1.128/25'
            destinationAddressPrefix: '10.0.1.128/25'
            access: 'Allow'
            priority: 300
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow_Outbound_subnet'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: '10.0.1.128/25'
            destinationAddressPrefix: '10.0.1.128/25'
            access: 'Allow'
            priority: 100
            direction: 'Outbound'
          }
        }
      ]
    }
    {
      name: 'snet-app'
      addressPrefix: subnets['snet-app']
      delegation: 'Microsoft.Web/serverFarms'
    }
    {
      name: 'snet-pep'
      addressPrefix: subnets['snet-pep']
    }
  ]
}

param vms = [
  {
    name: 'vmmgmt01'
    rgName: 'rg-vmmgmt01'
    availabilitySetName: ''
    tags: {
      Application: 'Management'
      Service: 'Management'
      UpdateManagement: 'Not_supported'
      Autoshutdown: 'No'
    }
    vmSize: 'Standard_B2ms'
    plan: {}
    imageReference: {
      publisher: 'microsoftwindowsserver'
      offer: 'windowsserver'
      sku: '2022-datacenter-g2'
      version: 'latest'
    }
    osDiskSizeGB: 128
    dataDisks: [
      {
        name: 'dataDisk-0'
        storageAccountType: 'Premium_LRS'
        createOption: 'Empty'
        lun: 0
        diskSizeGB: 25
      }
    ]
    networkInterfaces: [
      {
        privateIPAllocationMethod: 'Static'
        privateIPAddress: '10.10.0.245'
        primary: true
        subnet: 'snet-mgmt'
        publicIPAddress: false
        enableIPForwarding: false
        enableAcceleratedNetworking: false
      }
    ]
    backup: {
      enabled: false
      rsvPolicyName: 'policy-vm7days01'
    }
    AzureMonitorAgentWin: true
  }
]
