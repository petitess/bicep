targetScope = 'resourceGroup'

param name string
param location string

var tags = resourceGroup().tags

resource avail 'Microsoft.Compute/availabilitySets@2022-08-01' = {
  name: '${name}-avail'
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

output id string = avail.id
