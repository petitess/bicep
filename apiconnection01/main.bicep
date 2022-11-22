targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rglogic 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-api-${env}-01'
}

module logic 'api.bicep' = {
  scope: rglogic
  name: 'module-${affix}-logic'
  params: {
    location: param.locationAlt
  }
}
