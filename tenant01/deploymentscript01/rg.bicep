targetScope = 'subscription'

param location string
param prefix string

resource rgGov 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${prefix}-01'
  location: location
}
