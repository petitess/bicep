using '../main.bicep'

param environment = 'dev'
param config = {
  product: 'infra'
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
    '10.100.9.0/24'
  ]
  flowLogsEnabled: false
  subnets: [
    {
      name: 'AzureFirewallSubnet'
      addressPrefix: '10.100.9.0/26'
    }
    {
      name: 'AzureBastionSubnet'
      addressPrefix: '10.100.9.64/26'
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
      addressPrefix: '10.100.9.128/27'
    }
    {
      name: 'snet-pep'
      addressPrefix: '10.100.9.160/27'
    }
  ]
}
