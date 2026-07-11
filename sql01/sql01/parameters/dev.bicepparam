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

param managedIdentities = [
  {
    name: 'id-abc-dev-01'
    rgName: 'rg-sql-system-dev-01'
  }
]

param sqls = [
  {
    name: 'sql-system-${env}-01'
    azureADOnlyAuthentication: true
    publicNetworkAccess: 'Enabled'
    allowedIPs: {
      OFFICE_IP: '1.1.1.1'
      HOME_IP: myIP
    }
    identity: 'None'
    privateIp: '10.10.1.70'
    databases: [
      {
        name: 'sqldb-elastic-job'
        collation: 'Finnish_Swedish_CI_AS'
        zoneRedundant: false
        sku: {
          name: 'BC_Gen5_2'
        }
      }
      {
        name: 'sqldb-elastic-pool'
        collation: 'Finnish_Swedish_CI_AS'
        zoneRedundant: false
        elasticPoolName: 'sqlep-job-01'
        sku: {
          name: 'ElasticPool'
        }
      }
    ]
    jobAgents: [
      {
        name: 'sqlja-elastic-job'
        dbName: 'sqldb-elastic-job'
        identity: true
        alert: false
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
    jobRbac: [
      {
        jobAgentName: 'sqlja-elastic-job'
        jobName: 'JobSelection'
        principalId: 'e6525bc3-ae2a-4b3f-ae6f-9f28a1367628'
        principalType: 'User'
      }
    ]
    targetGroups: [
      {
        name: 'tg-system'
        jobAgentName: 'sqlja-elastic-job'
      }
    ]
    jobs: [
      {
        name: 'JobSelection'
        enabled: true
        type: 'Recurring'
        interval: 'PT24H'
        jobAgentName: 'sqlja-elastic-job'
        steps: [
          {
            name: 'Step1'
            type: 'TSql'
            source: 'Inline'
            value: 'SELECT TOP 10 * FROM sys.tables'
            targetGroup: 'tg-default'
          }
          {
            name: 'Step2'
            type: 'TSql'
            source: 'Inline'
            value: 'SELECT TOP 10 * FROM sys.tables'
            targetGroup: 'tg-system'
          }
        ]
      }
      {
        name: 'JobSelectionNoRbac'
        enabled: true
        type: 'Recurring'
        interval: 'PT24H'
        jobAgentName: 'sqlja-elastic-job'
        steps: [
          {
            name: 'Step1'
            type: 'TSql'
            source: 'Inline'
            value: 'SELECT TOP 10 * FROM sys.tables'
            targetGroup: 'tg-default'
          }
        ]
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
