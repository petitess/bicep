using '../main.bicep'

param env = 'dev'
param location = 'swedencentral'
param tags = {
  Application: 'sys'
  Environment: 'test'
}
param myIP = '1.1.1.1'

var addressPrefixes = ['10.10.0.0/20']

var subnets = {
  GatewaySubnet: cidrSubnet(addressPrefixes[0], 26, 0)
  AzureFirewallSubnet: cidrSubnet(addressPrefixes[0], 26, 1)
  AzureBastionSubnet: cidrSubnet(addressPrefixes[0], 26, 2)
  'snet-mgmt': cidrSubnet(addressPrefixes[0], 26, 3)
  'snet-app': cidrSubnet(addressPrefixes[0], 26, 4)
  'snet-pep': cidrSubnet(addressPrefixes[0], 26, 5)
  'snet-app-flex': cidrSubnet(addressPrefixes[0], 26, 6)
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
      name: 'snet-app-flex'
      addressPrefix: subnets['snet-app-flex']
      delegation: 'Microsoft.App/environments'
    }
  ]
}

param funcApps = [
  {
    name: 'func-eventgrid-dev-01'
    resourceGroup: 'rg-func-eventgrid-dev-01'
    kind: 'functionapp,linux'
    // aspName: 'asp-linux-sys-dev-01'
    isFlexConsumptionTier: true
    storageName: 'stfunceventgriddev01'
    storageContainerName: 'func01'
    privateEndpoints: {
      sites: cidrSubnet(subnets['snet-pep'], 32, 5)
      'sites-stage': cidrSubnet(subnets['snet-pep'], 32, 9)
    }
    appSettings: [
      {
        name: 'MY_PROPERTY'
        value: '1234'
      }
    ]
    authEnabled: false
    // slot: {
    //   name: 'stage'
    //   authEnabled: false
    //   appSettings: [
    //     {
    //       name: 'MY_PROPERTY'
    //       value: '1234'
    //     }
    //     {
    //       name: 'WEBSITE_CONTENTSHARE'
    //       value: 'func02'
    //     }
    //   ]
    // }
  }
]

param storageAccounts = [
  {
    name: 'stfunceventgriddev01'
    resourceGroup: 'rg-func-eventgrid-dev-01'
    skuName: 'Standard_LRS'
    isSftpEnabled: false
    publicAccess: 'Enabled'
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
      'eventgrid-results'
    ]
  }
]
