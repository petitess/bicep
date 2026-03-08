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

param serviceBus = [
  {
    resourcegroup: 'rg-integration-dev-01'
    name: 'sb-system-dev-01'
    sku: 'Standard'
    ipAddress: '10.10.1.70'
    queues: [
      'sbq_system'
    ]
    allowIPs: [
      myIP
    ]
    topics: [
      {
        name: 'sbt-system'
        properties: {
          userMetadata: 'metadata for sbt-system topic'
        }
        subscriptions: [
          {
            name: 'system-to-crm-sub'
            properties: {
              userMetadata: 'metadata for system-to-crm-sub subscription'
            }
            rules: [
              {
                filterType: 'CorrelationFilter'
                correlationFilter: {
                  properties: {
                    weekday: 'lördag'
                  }
                }
              }
              {
                filterType: 'SqlFilter'
                sqlFilter: {
                  sqlExpression: '[property-name] = \'value\''
                }
              }
            ]
          }
          {
            name: 'system-to-fim-sub'
            properties: {
              userMetadata: 'metadata for system-to-fim-sub subscription'
            }
            rules: [
              {
                filterType: 'CorrelationFilter'
                correlationFilter: {
                  properties: {
                    weekday: 'fredag'
                  }
                }
              }
            ]
          }
          {
            name: 'system-to-sink-sub'
            properties: {
              userMetadata: 'metadata for system-to-sink-sub subscription'
            }
            rules: [
              {
                filterType: 'CorrelationFilter'
                correlationFilter: {
                  properties: {
                    weekday: 'torsdag'
                  }
                }
              }
            ]
          }
        ]
      }
      {
        name: 'sbt-logic'
        properties: {
          userMetadata: 'metadata for sbt-logic topic'
        }
        subscriptions: [
          {
            name: 'logic-to-crm-sub'
            properties: {
              userMetadata: 'metadata for logic-to-crm-sub subscription'
            }
            rules: [
              {
                filterType: 'CorrelationFilter'
                correlationFilter: {
                  properties: {
                    month: 'mars'
                  }
                }
              }
            ]
          }
          {
            name: 'logic-to-fim-sub'
            properties: {
              userMetadata: 'metadata for logic-to-fim-sub subscription'
            }
            rules: [
              {
                filterType: 'CorrelationFilter'
                correlationFilter: {
                  properties: {
                    weekday: 'tisdag'
                  }
                }
              }
            ]
          }
          {
            name: 'logic-to-sink-sub'
            properties: {
              userMetadata: 'metadata for logic-to-sink-sub subscription'
            }
            rules: [
              {
                filterType: 'CorrelationFilter'
                correlationFilter: {
                  properties: {
                    weekday: 'onsdag'
                  }
                }
              }
            ]
          }
        ]
      }
    ]
  }
]

param storageAccounts = [
  {
    name: 'stfuncsbtopicdev01'
    resourceGroup: 'rg-func-sb-topic-dev-01'
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
    ]
  }
]

param funcApps = [
  {
    name: 'func-sb-topic-dev-01'
    resourceGroup: 'rg-func-sb-topic-dev-01'
    kind: 'functionapp,linux'
    isFlexConsumptionTier: true
    storageName: 'stfuncsbtopicdev01'
    storageContainerName: 'func01'
    runtimeName: 'python'
    runtimeVersion: '3.14'
    privateEndpoints: {
      sites: cidrSubnet(subnets['snet-pep'], 32, 5)
      'sites-stage': cidrSubnet(subnets['snet-pep'], 32, 9)
    }
    appSettings: [
      {
        name: 'SERVICEBUS_CONNECTION'
        value: 'Endpoint=sb://sb-system-dev-01.servicebus.windows.net/;SharedAccessKeyName=access;SharedAccessKey=blabla=;EntityPath=sbt-logic'
      }
      {
        name: 'SUBSCRIPTION_NAME'
        value: 'logic-to-crm-sub'
      }
      {
        name: 'TOPIC_NAME'
        value: 'sbt-logic'
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
