targetScope = 'subscription'

param config object

var affix = toLower('${config.environment.affix}-${config.location.affix}')
var location = config.location.name
var tags = {
  Company: config.company.affix
  Environment: config.environment.name
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${affix}-01'
  location: location
  tags: tags
}

module cert 'certificates.bicep' = {
  scope: rg
  name: 'module-certificates'
}
