targetScope = 'subscription'

param param object
param env string

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

resource rgInfra 'Microsoft.Resources/resourceGroups@2022-09-01' ={
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module st 'st.bicep' = {
  scope: rgInfra
  name: 'module-st'
  params: {
    location: param.location
    name: 'st346456345${env}01'
    stDiagId: stDiag.outputs.id
  }
}

module stDiag 'stDiag.bicep' = {
  scope: rgInfra
  name: 'module-stDiag'
  params: {
    location: param.location
    name: 'stdiag0000${env}01'
  }
}

module app 'app.bicep' = {
  scope: rgInfra
  name: 'module-app'
  params: {
    env: env
    location: param.location
    stId: stDiag.outputs.id
  }
}

