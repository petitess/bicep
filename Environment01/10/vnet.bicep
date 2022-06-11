targetScope = 'resourceGroup'

param name string
param location string 
param addressPrefixes array
param dnsServers array
param subnets array

var tags = resourceGroup().tags

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: name
  tags: tags
  location: location
  properties: {
  addressSpace: {
    addressPrefixes: addressPrefixes
  } 
  dhcpOptions: {
    dnsServers: dnsServers
  }
  subnets: [for (subnet, i) in subnets: {
    name: subnet.name
    properties: {
      addressPrefix: subnet.addressPrefix
      networkSecurityGroup: subnet.networkSecurityGroup ? { 
        id: nsg[i].id 
      } : null
    }

  }]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = [for subnet in subnets: if (subnet.networkSecurityGroup) {
  name: 'nsg-${subnet.name}'
  location: location
  tags: tags
  properties:{
    securityRules: subnet.securityRules
      }
}]

output vnetid string = vnet.id
