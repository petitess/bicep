using '../main.bicep'

var addressPrefix = '10.100.9.0/24'

param environment = 'dev'
param config = {
  product: 'xxx'
  location: 'we'
  tags: {
    Product: 'Common Infrastructure'
    Environment: 'Development'
    CostCenter: '0000'
  }
}
param kv = {
  sku: 'standard'
  enabledForDeployment: false
  enabledForTemplateDeployment: true
  enabledForDiskEncryption: true
  enableRbacAuthorization: true
}
param vnet = {
  addressPrefixes: [
    addressPrefix
  ]
  flowLogsEnabled: false
  subnets: [
    {
      name: 'AzureFirewallSubnet'
      addressPrefix: cidrSubnet(addressPrefix, 27, 0)
    }
    {
      name: 'AzureBastionSubnet'
      addressPrefix: cidrSubnet(addressPrefix, 27, 1)
      rules: [
        {
          name: 'nsgsr-allow-gatewaymanager-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'GatewayManager'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 100
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-azureloadbalancer-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'AzureLoadBalancer'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 200
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-https-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'Internet'
            sourcePortRange: '*'
            destinationAddressPrefix: '*'
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 300
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-bastion-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'VirtualNetwork'
            sourcePortRange: '*'
            destinationAddressPrefix: 'VirtualNetwork'
            destinationPortRanges: [
              '8080'
              '5701'
            ]
            protocol: 'Tcp'
            priority: 400
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-http-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: 'Internet'
            destinationPortRange: '80'
            protocol: 'Tcp'
            priority: 100
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-https-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: 'AzureCloud'
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 200
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-rdp-ssh-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: 'VirtualNetwork'
            destinationPortRanges: [
              '22'
              '3389'
            ]
            protocol: 'Tcp'
            priority: 300
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-bastion-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'VirtualNetwork'
            sourcePortRange: '*'
            destinationAddressPrefix: 'VirtualNetwork'
            destinationPortRanges: [
              '8080'
              '5701'
            ]
            protocol: 'Tcp'
            priority: 400
            direction: 'Outbound'
          }
        }
      ]
    }
    {
      name: 'GatewaySubnet'
      addressPrefix: cidrSubnet(addressPrefix, 27, 2)
    }
    {
      name: 'snet-pep'
      addressPrefix: cidrSubnet(addressPrefix, 27, 3)
      defaultRules: 'None'
      rules: []
    }
    {
      name: 'snet-dbw-private'
      addressPrefix: cidrSubnet(addressPrefix, 27, 4)
      delegation: 'Microsoft.Databricks/workspaces'
      defaultRules: 'None'
      rules: [
        {
          name: 'nsgsr-allow-dbw-vnet-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'VirtualNetwork'
            sourcePortRange: '*'
            destinationAddressPrefix: 'VirtualNetwork'
            destinationPortRange: '*'
            protocol: 'Tcp'
            priority: 500
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-dbw-vnet-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'VirtualNetwork'
            sourcePortRange: '*'
            destinationAddressPrefix: 'VirtualNetwork'
            destinationPortRange: '*'
            protocol: '*'
            priority: 500
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-dbw-sql-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'VirtualNetwork'
            sourcePortRange: '*'
            destinationAddressPrefix: 'Sql'
            destinationPortRange: '3306'
            protocol: 'Tcp'
            priority: 510
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-dbw-st-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'VirtualNetwork'
            sourcePortRange: '*'
            destinationAddressPrefix: 'Storage'
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 520
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-dbw-eventhub-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'VirtualNetwork'
            sourcePortRange: '*'
            destinationAddressPrefix: 'EventHub'
            destinationPortRange: '9093'
            protocol: '*'
            priority: 530
            direction: 'Outbound'
          }
        }
      ]
    }
    {
      name: 'snet-dbw-public'
      addressPrefix: cidrSubnet(addressPrefix, 27, 5)
      delegation: 'Microsoft.Databricks/workspaces'
      defaultRules: 'None'
      rules: [
        {
          name: 'nsgsr-allow-dbw-vnet-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'VirtualNetwork'
            sourcePortRange: '*'
            destinationAddressPrefix: 'VirtualNetwork'
            destinationPortRange: '*'
            protocol: 'Tcp'
            priority: 500
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-dbw-vnet-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'VirtualNetwork'
            sourcePortRange: '*'
            destinationAddressPrefix: 'VirtualNetwork'
            destinationPortRange: '*'
            protocol: '*'
            priority: 500
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-dbw-sql-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'VirtualNetwork'
            sourcePortRange: '*'
            destinationAddressPrefix: 'Sql'
            destinationPortRange: '3306'
            protocol: 'Tcp'
            priority: 510
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-dbw-st-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'VirtualNetwork'
            sourcePortRange: '*'
            destinationAddressPrefix: 'Storage'
            destinationPortRange: '443'
            protocol: 'Tcp'
            priority: 520
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-dbw-eventhub-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: 'VirtualNetwork'
            sourcePortRange: '*'
            destinationAddressPrefix: 'EventHub'
            destinationPortRange: '9093'
            protocol: '*'
            priority: 530
            direction: 'Outbound'
          }
        }
      ]
    }
    {
      name: 'snet-mgmt'
      addressPrefix: cidrSubnet(addressPrefix, 27, 6)
      rules: []
    }
  ]
}
