using 'main.bicep'

param param = {
  location: 'SwedenCentral'
  locationAlt: 'WestEurope'
  tags: {
    Application: 'Infra'
    Environment: 'Dev'
  }
  maintenanceConfigurations: [
    {
      name: 'mc-dynamic-dev-01'
      recurEvery: '1Month Last Sunday'
      detectionTags: {
        UpdateManagement: [
          'Critical_Monthly_GroupB'
        ]
      }
    }
    {
      name: 'mc-dynamic-dev-02'
      recurEvery: '1Month Third Monday'
      detectionTags: {
        UpdateManagement: [
          'Critical_Monthly_GroupA'
        ]
      }
    }
  ]
  vnet: {
    addressPrefixes: [
      '10.0.0.0/20'
    ]
    dnsServers: []
    peerings: []
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
      name: 'vmabcdev01'
      tags: {
        Application: 'Core'
        Service: 'ActiveDirectory'
        UpdateManagement: 'Critical_Monthly_GroupA'
      }
      vmSize: 'Standard_B2s'
      plan: {}
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDiskSizeGB: 128
      dataDisks: []
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.0.1.133'
          primary: true
          subnet: 'snet-mgmt'
          publicIPAddress: false
          enableIPForwarding: false
          enableAcceleratedNetworking: false
          applicationGatewayBackend: true
        }
      ]
    }
    {
      name: 'vmabcdev02'
      tags: {
        Application: 'Core'
        Service: 'ActiveDirectory'
        UpdateManagement: 'Critical_Monthly_GroupB'
      }
      vmSize: 'Standard_B2s'
      plan: {}
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDiskSizeGB: 128
      dataDisks: []
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.0.1.134'
          primary: true
          subnet: 'snet-mgmt'
          publicIPAddress: false
          enableIPForwarding: false
          enableAcceleratedNetworking: false
          applicationGatewayBackend: true
        }
      ]
    }
    {
      name: 'vmlinuxdev01'
      tags: {
        Application: 'Core'
        Service: 'ActiveDirectory'
        UpdateManagement: 'Critical_Monthly_GroupA'
      }
      vmSize: 'Standard_B1ms'
      plan: {}
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDiskSizeGB: 64
      dataDisks: []
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.0.1.135'
          primary: true
          subnet: 'snet-mgmt'
          publicIPAddress: false
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
    }
  ]
}
