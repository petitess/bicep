using 'main.bicep'

param env = 'test'
param location = 'swedencentral'
param tags = {
  Application: 'sys'
  Environment: 'test'
}
param pdnsz = {
  domains: [
    'privatelink.sdc.backup.windowsazure.com'
    'privatelink.queue.core.windows.net'
    'privatelink.blob.core.windows.net'
  ]
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
      name: 'snet-pep'
      addressPrefix: '10.0.2.128/25'
    }
  ]
}
