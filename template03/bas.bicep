targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param subnet string

resource bas 'Microsoft.Network/bastionHosts@2022-09-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
        name: '${name}-ipConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: 'pip-${name}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

output id string = bas.id
output name string = bas.name
