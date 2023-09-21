targetScope = 'subscription'

param param object

var env = toLower(param.tags.Environment)
var vdaCount = 20

resource rgVda 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: toLower('rg-vmvdaprod01')
}

module vda 'tags.bicep' = {
  scope: rgVda
  name: 'module-vda-${env}'
  params: {
    vdaCount: vdaCount
  }
}
