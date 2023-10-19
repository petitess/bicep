using 'main.bicep'

param environment = 'test'
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
          {
            name: 'nsgsr-allow-inbound'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
              access: 'Allow'
              priority: 200
              direction: 'Inbound'
            }
          }
          {
            name: 'nsgsr-allow-outbound'
            properties: {
              protocol: '*'
              sourcePortRange: '*'
              destinationPortRange: '*'
              sourceAddressPrefix: '*'
              destinationAddressPrefix: '*'
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
  vmss: [
    {
      name: 'vmdevops'
      instance: 1
      tags: {
        Application: 'DevOps'
        Service: 'DevOps Agent Linux'
      }
      vmSize: 'Standard_B2s'
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-lunar'
        sku: '23_04'
        version: 'latest'
      }
      osDiskSizeGB: 128
      dataDisks: []
      networkInterfaces: [
        {
          primary: true
          subnet: 'snet-mgmt'
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
    }
    {
      name: 'vmdevops'
      instance: 2
      tags: {
        Application: 'DevOps'
        Service: 'DevOps Agent Windows'
      }
      vmSize: 'Standard_B2s'
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter-smalldisk'
        version: 'latest'
      }
      osDiskSizeGB: 70
      dataDisks: []
      networkInterfaces: [
        {
          primary: true
          subnet: 'snet-mgmt'
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
    }
  ]
}
