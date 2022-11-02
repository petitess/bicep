targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rgapp 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: union(param.tags, {
    Service: 'Google Tag Manager'
  })
  name: 'rg-app-gtm-${env}-01'
}

module appgtm 'appgtm.bicep' = {
  scope: rgapp
  name: 'module-${affix}-appgtm'
  params: {
    affix: env
    location: rgapp.location
  }
}




