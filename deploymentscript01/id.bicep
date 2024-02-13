param name string
param location string
param tags object

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: name
  location: location
  tags: tags
}

output principalId string = id.properties.principalId
