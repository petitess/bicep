targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags

resource avail 'Microsoft.Compute/availabilitySets@2022-08-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: 3
    platformUpdateDomainCount: 20
  }
}
