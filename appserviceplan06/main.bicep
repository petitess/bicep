targetScope = 'subscription'

param param object

var env = toLower(param.tags.Environment)

resource rgApp 'Microsoft.Resources/resourceGroups@2022-09-01' ={
  location: param.location
  tags: param.tags
  name: 'rg-app-${env}-01'
}

module appGtm 'app.bicep' = {
  scope: rgApp
  name: 'module-app'
  params: {
    env: toLower(param.tags.Environment)
    location: param.location
  }
}
