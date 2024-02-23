using 'main.bicep'

param env = 'test'
param location = 'swedencentral'
param tags = {
  Application: 'sys'
  Environment: 'test'
}
param vnet = {
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
        // {

        //   name: 'Allow_Inbound_Web'
        //   properties: {
        //     protocol: '*'
        //     sourcePortRange: '*'
        //     destinationPortRange: '80'
        //     sourceAddressPrefix: 'Internet'
        //     destinationAddressPrefix: '10.0.1.133'
        //     access: 'Allow'
        //     priority: 100
        //     direction: 'Inbound'

        //   }
        // }
        {

          name: 'Allow_Inbound_Rdp'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '3389'
            sourceAddressPrefix: '188.150.99.238/32'
            destinationAddressPrefix: '10.0.1.128/25'
            access: 'Allow'
            priority: 200
            direction: 'Inbound'

          }
        }
        {

          name: 'Allow_Inbound_subnet'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: '10.0.1.128/25'
            destinationAddressPrefix: '10.0.1.128/25'
            access: 'Allow'
            priority: 300
            direction: 'Inbound'

          }
        }
        {

          name: 'Allow_Outbound_subnet'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: '10.0.1.128/25'
            destinationAddressPrefix: '10.0.1.128/25'
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
param vms = [
  {
    name: 'vmabc01'
    tags: {
      Application: 'App'
      Service: 'Srv'
      UpdateManagement: 'NotSupported'
    }
    vmSize: 'Standard_D2ads_v5'
    plan: {}
    imageReference: {
      publisher: 'microsoftwindowsserver'
      offer: 'windowsserver'
      sku: '2022-datacenter-g2'
      version: 'latest'
    }
    osDiskSizeGB: 164
    dataDisks: [
      {
        name: 'dataDisk-0'
        storageAccountType: 'Premium_LRS'
        createOption: 'Empty'
        caching: 'ReadWrite'
        lun: 0
        diskSizeGB: 200
        tier: 'P50'
      }
      {
        name: 'dataDisk-1'
        storageAccountType: 'Premium_LRS' //'UltraSSD_LRS'
        createOption: 'Empty'
        caching: 'None'
        lun: 1
        diskSizeGB: 4200
        tier: 'P80'
      }
      {
        name: 'dataDisk-2'
        storageAccountType: 'Premium_LRS' //'UltraSSD_LRS'
        createOption: 'Empty'
        caching: 'None'
        lun: 2
        diskSizeGB: 4200
        tier: 'P60'
      }
    ]
    networkInterfaces: [
      {
        privateIPAllocationMethod: 'Static'
        privateIPAddress: '10.0.1.133'
        primary: true
        subnet: 'snet-mgmt'
        publicIPAddress: true
        enableIPForwarding: false
        enableAcceleratedNetworking: true
      }
    ]
  }
  {
    name: 'vmsql01'
    tags: {
      Application: 'App'
      Service: 'Sql'
      UpdateManagement: 'NotSupported'
    }
    vmSize: 'Standard_D2ads_v5'
    plan: {}
    imageReference: {
      publisher: 'microsoftsqlserver'
      offer: 'sql2022-ws2022'
      sku: 'sqldev-gen2'
      version: 'latest'
    }
    osDiskSizeGB: 164
    dataDisks: [
      {
        name: 'dataDisk-0'
        storageAccountType: 'Premium_LRS' //'UltraSSD_LRS'
        createOption: 'Empty'
        caching: 'ReadWrite'
        lun: 0
        diskSizeGB: 200
        //tier: 'P50'
      }
      {
        name: 'dataDisk-1'
        storageAccountType: 'Premium_LRS' //'UltraSSD_LRS'
        createOption: 'Empty'
        caching: 'None'
        lun: 1
        diskSizeGB: 4200
        //tier: 'P80'
      }
      {
        name: 'dataDisk-2'
        storageAccountType: 'Premium_LRS' //'UltraSSD_LRS'
        createOption: 'Empty'
        caching: 'None'
        lun: 2
        diskSizeGB: 4200
        tier: 'P60'
      }
    ]
    networkInterfaces: [
      {
        privateIPAllocationMethod: 'Static'
        privateIPAddress: '10.0.1.134'
        primary: true
        subnet: 'snet-mgmt'
        publicIPAddress: true
        enableIPForwarding: false
        enableAcceleratedNetworking: true
      }
    ]
  }
]
