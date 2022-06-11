targetScope = 'resourceGroup'

param name string
param location string

var tags = resourceGroup().tags

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: name
  location: location
  tags: tags
}


output id string = id.properties.principalId
