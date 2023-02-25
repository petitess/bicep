targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param vnetname string

resource bas 'Microsoft.Network/bastionHosts@2022-07-01' = {
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
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, 'AzureBastionSubnet')
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${name}-pip'
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
