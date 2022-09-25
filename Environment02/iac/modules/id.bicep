targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: name
  location: location
  tags: tags
}

output id string = id.id
output name string = id.name
output principalId string = id.properties.principalId
