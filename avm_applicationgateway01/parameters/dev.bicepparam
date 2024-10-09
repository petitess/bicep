using '../main.bicep'

param environment = 'dev'
param config = {
  product: 'abc'
  location: 'we'
  tags: {
    Product: 'Common Infrastructure'
    Environment: 'Development'
    CostCenter: '0000'
  }
}

param addressPrefixes = ['10.10.1.0/24', '10.10.10.0/24']

param subnets = [
  {
    name: 'GatewaySubnet'
    addressPrefix: cidrSubnet(addressPrefixes[1], 24, 0)
    securityRules: []
  }
  {
    name: 'snet-agw'
    addressPrefix: cidrSubnet(addressPrefixes[0], 26, 0)
    securityRules: [
      {
        name: 'nsgsr-allow-gatewaymanager-inbound'
        properties: {
          access: 'Allow'
          sourceAddressPrefix: 'GatewayManager'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '65200-65535'
          protocol: 'Tcp'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'nsgsr-allow-gatewaymanager-inbound-private'
        properties: {
          access: 'Allow'
          sourceAddressPrefix: 'GatewayManager'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '443'
            '80'
          ]
          protocol: 'Tcp'
          priority: 150
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
          destinationPortRange: '65200-65535'
          protocol: 'Tcp'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'nsgsr-allow-internet-inbound'
        properties: {
          access: 'Allow'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '10.100.6.0/24'
          destinationPortRanges: [
            '80'
            '443'
          ]
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
        name: 'nsgsr-allow-vpn-inbound'
        properties: {
          access: 'Allow'
          sourceAddressPrefix: '172.20.0.0/24'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          protocol: 'Tcp'
          priority: 300
          direction: 'Inbound'
        }
      }
    ]
  }
  {
    name: 'snet-app-outbound'
    addressPrefix: cidrSubnet(addressPrefixes[0], 26, 2)
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
  {
    name: 'snet-ai'
    addressPrefix: cidrSubnet(addressPrefixes[0], 26, 3)
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    serviceEndpoints: [
      'Microsoft.CognitiveServices'
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
