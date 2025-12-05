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

param sqls = [
  {
    name: 'sql-system-infra-${env}-01'
    adminGroupName: 'grp-rbac-mg-root-Owner'
    adminGroupObjectId: '9b31210f-74d6-4f97-8b1d-ae1196e17ab8'
    azureADOnlyAuthentication: true
    publicNetworkAccess: 'Enabled'
    allowedIPs: {
      OFFICE_IP: '1.1.1.1' 
      HOME_IP: '1.1.2.2' 
    }
    identity: 'None'
    privateIp: '10.10.1.68'
    databases: [
      {
        name: 'sqldb-elastic-job'
        collation: 'Finnish_Swedish_CI_AS'
        zoneRedundant: false
        sku: {
          name: 'BC_Gen5_2'
        }
      }
    ]
    jobAgents: [
      {
        name: 'sqlja-elastic-job'
        dbName: 'sqldb-elastic-job'
        alert: false
        identity: false
        sku: {
          name: 'JA100'
          capacity: 100
        }
      }
    ]
    elasticPools: [
      {
        name: 'sqlep-job-01'
        sku: {
          name: 'PremiumPool'
        }
      }
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
