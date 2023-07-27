using 'main.bicep'

param param = {
  location: 'SwedenCentral'
  tags: {
    Application: 'sys'
    Environment: 'dev'
  }
  vnet: {
    addressPrefixes: [
      '10.0.0.0/20'
    ]
    subnets: [
      {
        name: 'snet-mgmt'
        addressPrefix: '10.0.0.0/25'
        routes: []
      }
      {
        name: 'snet-app'
        addressPrefix: '10.0.0.128/25'
        rules: [
          {
            name: 'nsgsr-deny-all-inbound'
            properties: {
              access: 'Deny'
              sourceAddressPrefix: '*'
              sourcePortRange: '*'
              destinationAddressPrefix: '*'
              destinationPortRange: '*'
              protocol: '*'
              priority: 4096
              direction: 'Inbound'
            }
          }
        ]
      }
      {
        name: 'snet-inbound'
        addressPrefix: '10.0.1.0/25'
      }
      {
        name: 'snet-outbound'
        addressPrefix: '10.0.1.128/25'
        delegation: 'Microsoft.Web/serverFarms'
        rules: []
      }
    ]
  }
}
