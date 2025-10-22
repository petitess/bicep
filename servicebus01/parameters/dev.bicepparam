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

param serviceBus = [
  {
    resourcegroup: 'rg-integration-dev-01'
    name: 'sb-integration-dev-01'
    sku: 'Standard'
    ipAddress: '10.10.1.70'
    queues: [
      'my_queue'
    ]
    allowIPs: [
      myIP
    ]
    subscriptions_topics: {
      'cm1-to-crm-sub': 'sbt-cm1-updates-dev-sc-01'
      'cm1-to-fim-sub': 'sbt-cm1-updates-dev-sc-01'
      'cm1-to-sink-sub': 'sbt-cm1-updates-dev-sc-01'
      'maxa-to-crm-sub': 'sbt-maxa-events-dev-sc-01'
      'maxa-to-sink-sub': 'sbt-maxa-events-dev-sc-01'
    }
    rbac: [
      // {
      //   principalId: '81f92e5e-9db5-4eea-85eb-ec8e0a8d601d'
      //   role: 'Azure Service Bus Data Owner'
      // }
    ]
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
