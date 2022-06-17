targetScope = 'resourceGroup'

param name string
param location string
param subnet string

var tags = resourceGroup().tags

resource bastion 'Microsoft.Network/bastionHosts@2021-08-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
        name: '${name}-ip01'
        properties: {
          subnet: {
            id: subnet
          }
          publicIPAddress: {
            id: basstionpip.id
          }
        }
      }
    ]
  }
}

resource basstionpip 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: '${name}-pip01'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
