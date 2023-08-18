using 'main.bicep'

param param = {
  location: 'SwedenCentral'
  locationAlt: 'WestEurope'
  tags: {
    Application: 'sys'
    Environment: 'test'
  }
  vnet: {
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

            name: 'Allow_Inbound_Web'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '80'
              sourceAddressPrefix: 'Internet'
              destinationAddressPrefix: '10.0.1.133'
              access: 'Allow'
              priority: 100
              direction: 'Inbound'

            }
          }
          {
            name: 'Allow_Outbound_Monitor'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '10051'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '10.10.2.140/32'
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
        name: 'snet-vda'
        addressPrefix: '10.0.2.128/25'
      }
    ]
  }
}
