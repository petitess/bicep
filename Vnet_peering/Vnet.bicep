param Name string = 'vnet-01'
param Prefix string 
param Subnets array
param Location string = resourceGroup().location
param dnsServers array
 
resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: Name
  location: Location
  properties: {
    addressSpace: {
      addressPrefixes: [
        Prefix
      ]
    }
    dhcpOptions: {
      dnsServers: dnsServers
    }
    subnets: [for Subnet in Subnets: {
      name: Subnet.name
      properties: {
        addressPrefix: Subnet.Prefix
      }
    }]
  }
}
output name string = vnet.name
