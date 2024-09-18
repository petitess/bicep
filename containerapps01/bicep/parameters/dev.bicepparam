using '../main.bicep'

param environment = 'dev'
param location = 'swedencentral'
param config = {
  product: 'xxx'
  location: 'sc'
  tags: {
    Product: 'Common Infrastructure'
    Environment: 'Development'
    CostCenter: '0000'
  }
}

param addressPrefixes = ['10.10.10.0/24']

param subnets = [
  {
    name: 'snet-default'
    addressPrefix: cidrSubnet(addressPrefixes[0], 26, 0)
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
    addressPrefix: cidrSubnet(addressPrefixes[0], 26, 1)
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
    name: 'snet-cae-outbound'
    addressPrefix: cidrSubnet(addressPrefixes[0], 26, 2)
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    delegations: [
      {
        name: 'Microsoft.App/environments'
        properties: {
          serviceName: 'Microsoft.App/environments'
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
