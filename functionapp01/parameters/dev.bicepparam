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
  'snet-app-flex': cidrSubnet(addressPrefixes[0], 26, 6)
}

param storageAccounts = [
  {
    name: 'stfuncaifdev01'
    resourceGroup: 'rg-func-aif-dev-01'
    skuName: 'Standard_LRS'
    isSftpEnabled: false
    publicAccess: 'Enabled'
    allowedIPs: [
      myIP
    ]
    privateEndpoints: {
      blob: cidrSubnet(subnets['snet-pep'], 32, 6)
      // file: cidrSubnet(subnets['snet-pep'], 32, 7)
    }
    shares: []
    containers: [
      'func01'
      'backup'
      'cpu'
      'sql'
      'anomalies'
      'virtual-machines'
      'uncategorised'
      'service-error'
    ]
  }
]

param funcApps = [
  {
    name: 'func-aif-dev-01'
    resourceGroup: 'rg-func-aif-dev-01'
    kind: 'functionapp,linux'
    isFlexConsumptionTier: true
    storageName: 'stfuncaifdev01'
    storageContainerName: 'func01'
    runtimeName: 'python'
    runtimeVersion: '3.12'
    privateEndpoints: {
      sites: cidrSubnet(subnets['snet-pep'], 32, 5)
      'sites-stage': cidrSubnet(subnets['snet-pep'], 32, 9)
    }
    appSettings: [
      {
        name: 'AZURE_OPENAI_ENDPOINT'
        value: 'https://aif-czr-dev-01.openai.azure.com/'
      }
      {
        name: 'AZURE_OPENAI_DEPLOYMENT_NAME'
        value: 'gpt-5.3-chat-lab'
      }
      {
        name: 'ST_NAME'
        value: 'stfuncaifdev01'
      }
      {
        name: 'AZURE_RESOURCE_GROUP'
        value: 'rg-aif-czr-dev-01'
      }
      {
        name: 'AZURE_ML_WORKSPACE_NAME'
        value: 'proj-function'
      }
    ]
    authEnabled: false
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
    {
      name: 'snet-app-flex'
      addressPrefix: subnets['snet-app-flex']
      delegation: 'Microsoft.App/environments'
    }
  ]
}
