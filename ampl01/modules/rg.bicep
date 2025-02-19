targetScope = 'subscription'

param name string
param location string
param tags object

resource rgRm 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: name
  location: location
  tags: union(tags, {
    System: 'Resource Manager'
  })
}
