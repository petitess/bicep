using '../main.bicep'

param env = 'dev'
param location = 'swedencentral'
param tags = {
  Application: 'sys'
  Environment: 'test'
}
param vnet = {
  addressPrefixes: [
    '10.0.0.0/20'
  ]
  subnets: [
    {
      name: 'GatewaySubnet'
      addressPrefix: '10.0.0.0/25'
    }
    {
      name: 'AzureFirewallSubnet'
      addressPrefix: '10.0.0.128/25'
    }
    {
      name: 'AzureBastionSubnet'
      addressPrefix: '10.0.1.0/25'
    }
    {
      name: 'snet-mgmt'
      addressPrefix: '10.0.1.128/25'
      rules: [
        {
          name: 'Allow_Inbound_Rdp'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '3389'
            sourceAddressPrefix: '188.150.99.11/32'
            destinationAddressPrefix: '10.0.1.128/25'
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
      name: 'snet-web'
      addressPrefix: '10.0.2.0/25'
    }
    {
      name: 'snet-pep'
      addressPrefix: '10.0.2.128/25'
    }
  ]
}

param storageAccounts = [
  {
    name: 'stcontactservicetest01'
    rgName: 'rg-st-${env}-01'
    skuName: 'Standard_LRS'
    isSftpEnabled: false
    publicAccess: 'Enabled'
    allowedIPs: []
    privateEndpoints: {
      blob: '10.0.2.135'
      file: '10.0.2.136'
    }
    shares: []
    containers: []
  }
]
