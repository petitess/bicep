param name string
param location string
param tags object = resourceGroup().tags
param subnet string
param vnetId string
@allowed(['Developer', 'Basic', 'Standard'])
param sku string = 'Basic'

resource bas 'Microsoft.Network/bastionHosts@2023-09-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    virtualNetwork: sku == 'Developer' ? {
      id: vnetId
    } : null
    ipConfigurations: sku != 'Developer' ? [
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
    ] : []
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
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
