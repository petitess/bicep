using '../main.bicep'

var addressPrefix = '10.100.9.0/24'

param environment = 'dev'
param config = {
  product: 'xxx'
  location: 'sc'
  tags: {
    Product: 'Common Infrastructure'
    Environment: 'Development'
    CostCenter: '0000'
  }
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
      rules: [
        {
          name: 'nsgsr-allow-storage-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefixes: [
              cidrSubnet(addressPrefix, 27, 4)
              cidrSubnet(addressPrefix, 27, 5)
            ]
            sourcePortRange: '*'
            destinationAddressPrefix: 'Storage'
            destinationPortRanges: ['443', '445']
            protocol: 'Tcp'
            priority: 100
            direction: 'Inbound'
          }
        }
      ]
    }
    {
      name: 'snet-func-linux-outbound'
      addressPrefix: cidrSubnet(addressPrefix, 27, 4)
      delegation: 'Microsoft.Web/serverFarms'
      rules: [
        {
          name: 'nsgsr-allow-storage-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: cidrSubnet(addressPrefix, 27, 3)
            destinationPortRanges: ['443', '445']
            protocol: 'Tcp'
            priority: 100
            direction: 'Outbound'
          }
        }
      ]
    }
    {
      name: 'snet-func-windows-outbound'
      addressPrefix: cidrSubnet(addressPrefix, 27, 5)
      delegation: 'Microsoft.Web/serverFarms'
      rules: [
        {
          name: 'nsgsr-allow-storage-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationAddressPrefix: cidrSubnet(addressPrefix, 27, 3)
            destinationPortRanges: ['443', '445']
            protocol: 'Tcp'
            priority: 100
            direction: 'Outbound'
          }
        }
      ]
    }
    {
      name: 'snet-mgmt'
      addressPrefix: cidrSubnet(addressPrefix, 27, 6)
    }
  ]
}
