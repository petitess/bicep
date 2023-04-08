targetScope = 'subscription'

param location string
param prefix string
param tags object

resource rgGov 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${prefix}-01'
  location: location
  tags: tags
}
