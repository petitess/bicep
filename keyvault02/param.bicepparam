using 'main.bicep'

param myIp = '188.150.99.111'
param config = {
  location: 'SwedenCentral'
  locationAlt: 'WestEurope'
  tags: {
    Application: 'Infra'
    Environment: 'Test'
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
            sourceAddressPrefix: myIp
            destinationAddressPrefix: '10.0.1.128/25'
            access: 'Allow'
            priority: 200
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow_Inbound_vnet'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Allow'
            priority: 300
            direction: 'Inbound'
          }
        }
        {
          name: 'Allow_Outbound_vnet'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'VirtualNetwork'
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
    {
      name: 'snet-st'
      addressPrefix: '10.0.3.0/28'
      serviceEndpoints: [
        {
          locations: [
            'swedencentral'
            'swedensouth'
          ]
          service: 'Microsoft.Storage'
        }
      ]
      delegation: 'Microsoft.ContainerInstance/containerGroups'
    }
  ]
}
