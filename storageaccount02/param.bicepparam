using 'main.bicep'

param param = {
  location: 'SwedenCentral'
  locationAlt: 'WestEurope'
  tags: {
    Application: 'Infra'
    Environment: 'test'
  }
  storageAccounts: [
    {
      name: 'stapplicationxxxx01'
      sku: 'Standard_GRS'
      containersCount: 3
      publicNetworkAccess: 'Disabled'
      shares: [
        {
          name: 'share01'
          backup: false
        }
      ]
    }
    {
      name: 'stapplicationxxxx02'
      sku: 'Standard_GRS'
      containersCount: 5
      publicNetworkAccess: 'Enabled'
      shares: [
        {
          name: 'share01'
          backup: false
        }
        {
          name: 'share02'
          backup: false
        }
        {
          name: 'share03'
          backup: false
        }
      ]
    }
  ]
  vnet: {
    addressPrefixes: [
      '10.0.0.0/24'
    ]
    subnets: [
      {
        name: 'snet-mgmt'
        addressPrefix: '10.0.0.0/28'
        routes: []
      }
      {
        name: 'snet-app'
        addressPrefix: '10.0.0.16/28'
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
        name: 'snet-pep'
        addressPrefix: '10.0.0.32/28'
      }
    ]
  }
}
