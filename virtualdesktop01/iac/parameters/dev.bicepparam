using '../main.bicep'

param environment = 'dev'
param config = {
  product: 'avd'
  location: 'sc'
  tags: {
    Product: 'Virtual Desktop'
    Environment: 'Development'
    CostCenter: '0000'
  }
}
param vnet = {
  addressPrefixes: [
    '10.100.55.0/24'
  ]
  subnets: [
    {
      name: 'snet-vm'
      addressPrefix: '10.100.55.0/27'
      rules: [
        {
          name: 'nsgsr-allow-bastion-inbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '10.100.9.64/26'
            sourcePortRange: '*'
            destinationAddressPrefix: '10.100.55.0/27'
            destinationPortRanges: [
              22
              3389
            ]
            protocol: 'Tcp'
            priority: 100
            direction: 'Inbound'
          }
        }
        {
          name: 'nsgsr-allow-internet-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '10.100.55.0/24'
            sourcePortRange: '*'
            destinationAddressPrefix: 'Internet'
            destinationPortRange: '*'
            protocol: '*'
            priority: 100
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-infra-${environment}-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '10.100.55.0/24'
            sourcePortRange: '*'
            destinationAddressPrefix: '10.100.10.0/24'
            destinationPortRange: '*'
            protocol: '*'
            priority: 200
            direction: 'Outbound'
          }
        }
        {
          name: 'nsgsr-allow-all-spokes-outbound'
          properties: {
            access: 'Allow'
            sourceAddressPrefix: '10.100.55.0/24'
            sourcePortRange: '*'
            destinationAddressPrefix: '10.100.0.0/16'
            destinationPortRange: '*'
            protocol: '*'
            priority: 300
            direction: 'Outbound'
          }
        }
      ]
    }
    {
      name: 'snet-pep'
      addressPrefix: '10.100.55.32/27'
      rules: []
    }
  ]
}
