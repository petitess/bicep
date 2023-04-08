param prefix string
param location string
param tags object

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-script-${prefix}-01'
  location: location
  tags: tags
}
