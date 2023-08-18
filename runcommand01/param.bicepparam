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
            name: 'nsgsr-allow-rdp'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRanges: [
                '22'
                '3389'
              ]
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 100
              direction: 'Inbound'
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
  vm: [
    {
      name: 'vmabc01'
      tags: {
        Application: 'App'
        Service: 'Srv'
        UpdateManagement: 'NotSupported'
      }
      vmSize: 'Standard_B2s'
      plan: {}
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter-smalldisk'
        version: 'latest'
      }
      osDiskSizeGB: 64
      dataDisks: []
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.0.1.133'
          primary: true
          subnet: 'snet-mgmt'
          publicIPAddress: true
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
    }
  ]
}
