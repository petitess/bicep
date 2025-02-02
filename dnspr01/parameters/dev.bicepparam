using '../main.bicep'

param env = 'dev'
param location = 'swedencentral'
param tags = {
  Application: 'sys'
  Environment: 'test'
}
param dnsServerIp = cidrHost(subnets['snet-dnspr'], 4)

var myIP = '1.1.1.1'
var addressPrefixes = ['10.10.0.0/20']

var subnets = {
  GatewaySubnet: cidrSubnet(addressPrefixes[0], 26, 0)
  AzureFirewallSubnet: cidrSubnet(addressPrefixes[0], 26, 1)
  AzureBastionSubnet: cidrSubnet(addressPrefixes[0], 26, 2)
  'snet-mgmt': cidrSubnet(addressPrefixes[0], 26, 3)
  'snet-app': cidrSubnet(addressPrefixes[0], 26, 4)
  'snet-pep': cidrSubnet(addressPrefixes[0], 26, 5)
  'snet-dnspr': cidrSubnet(addressPrefixes[0], 26, 6)
}

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
    {
      name: 'snet-dnspr'
      addressPrefix: subnets['snet-dnspr']
      delegation: 'Microsoft.Network/dnsResolvers'
    }
  ]
}

param storageAccounts = [
  {
    name: 'steventgriddev01'
    resourceGroup: 'rg-steventgriddev01'
    skuName: 'Standard_LRS'
    isSftpEnabled: false
    publicAccess: 'Disabled'
    allowedIPs: [
      myIP
    ]
    privateEndpoints: {
      blob: cidrSubnet(subnets['snet-pep'], 32, 6)
      file: cidrSubnet(subnets['snet-pep'], 32, 7)
    }
    shares: []
    containers: [
      'func01'
      'func02'
    ]
  }
]

param vms = [
  {
    name: 'vmdctest01'
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
      sku: '2022-datacenter-smalldisk'
      version: 'latest'
    }
    osDiskSizeGB: 64
    dataDisks: []
    networkInterfaces: [
      {
        privateIPAllocationMethod: 'Static'
        privateIPAddress: cidrSubnet(subnets['snet-mgmt'], 32, 6)
        primary: true
        subnet: 'snet-mgmt'
        publicIPAddress: true
        enableIPForwarding: false
        enableAcceleratedNetworking: false
        applicationGatewayBackend: true
      }
    ]
    AzureMonitorAgent: false
  }
]
