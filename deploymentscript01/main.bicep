targetScope = 'subscription'

param param object

var affix = toLower('groups-${param.tags.Environment}')

resource rginfra 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module script 'script.bicep' = {
  scope: rginfra
  name: 'module-groups'
  params: {
    location: param.location
    affix: affix
    tags: union(param.tags, {
      Application: 'Azure AD'
    })
  }
}

