targetScope = 'resourceGroup'

param name string
param location string

var tags = resourceGroup().tags

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
  tags: tags
}

output name string = id.name
output id string = id.id
output principalId string = id.properties.principalId
