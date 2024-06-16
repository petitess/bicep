using '../main.bicep'

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

param addressPrefixes = {
  dev: ['10.10.10.0/24']
}

param subnets = {
  dev: [
    {
      name: 'snet-default'
      addressPrefix: cidrSubnet(addressPrefixes[environment][0], 26, 0)
      securityRules: [
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
      ]
    }
    {
      name: 'snet-pep'
      addressPrefix: cidrSubnet(addressPrefixes[environment][0], 26, 1)
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      securityRules: [
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
      ]
    }
    {
      name: 'snet-app-outbound'
      addressPrefix: cidrSubnet(addressPrefixes[environment][0], 26, 2)
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      delegations: [
        {
          name: 'Microsoft.Web/serverfarms'
          properties: {
            serviceName: 'Microsoft.Web/serverfarms'
          }
        }
      ]
      securityRules: [
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
      ]
    }
  ]
}
