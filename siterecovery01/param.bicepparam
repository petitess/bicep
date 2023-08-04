using 'main.bicep'

param env = 'dev'
param param = {
  location: 'swedencentral'
  locationAsr: 'westeurope'
  tags: {
    Environment: env
  }
  vnet: {
    addressPrefixes: [
      '10.1.0.0/20'
    ]
    dnsServers: []
    name: 'vnet-${env}-01'
    peerings: []
    subnets: [
      {
        name: 'snet-vm'
        addressPrefix: cidrSubnet('10.1.0.0/20', 24, 0)
      }
      {
        name: 'snet-app'
        addressPrefix: cidrSubnet('10.1.0.0/20', 24, 1)
      }
    ]
  }
  vms: [
    {
      name: 'vmabc01'
      tags:{
        Application: 'App'
      }
      adminPassword: 'azadmin'
      adminUsername: '12345678.abc'
      vmSize: 'Standard_B4ms'
      osDiskSizeGB: 128
      dataDisks: [
        {
          name: 'dataDisk-0'
          storageAccountType: 'Premium_LRS'
          createOption: 'Empty'
          caching: 'ReadWrite'
          lun: 0
          diskSizeGB: 20
        }
      ]
      imageReference: {
        publisher: 'microsoftwindowsserver'
        offer: 'windowsserver'
        sku: '2022-datacenter'
        version: 'latest'
      }
      plan: {}
      networkInterfaces: [
        {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.1.0.11'
          primary: true
          subnet: 'snet-vm'
          publicIPAddress: false
          enableIPForwarding: false
          enableAcceleratedNetworking: false
        }
      ]
      backup: {
        siteRecovery: true
      }
    }
  ]
}
