targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rginfra 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-sc-01'
}

resource rglogic 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: union(param.tags, {
      Application: 'AD Password Expiration'
    })
  name: 'rg-logic-${env}-01'
}

module aa 'aa.bicep' = {
  scope: rginfra
  name: 'module-${affix}-aa'
  params: {
    location: param.location
    name: 'aa-${affix}-01'
    contributor: param.id.contributor
    keyvaultadmin: param.id.reader
  }
}

module id 'id.bicep' = {
  scope: rginfra
  name: 'module-${affix}-id'
  params: {
    location: param.location
    name: 'id-${affix}-01'
  }
}

module rbac 'rbac.bicep' = {
  name: 'module-${affix}-rbac'
  params: {
    principalId: id.outputs.principalId
    role01: param.id.keyvaultadmin
    role02: param.id.contributor
  }
}

module script 'script.bicep' = {
  scope: rginfra
  name: 'module-${affix}-script-infra'
  params: {
    idId: id.outputs.id
    location: param.locationAlt
    name: affix
    param: param
    aaname: aa.outputs.name
    aargname: rginfra.name
  }
}

module st01 'st.bicep' = {
  scope: rginfra
  name: 'module-st'
  params: {
    kind: 'StorageV2'
    location: param.location
    name: 'stkarol34525434drfg'
    sku: 'Standard_LRS'
  }
}

module logic 'logic.bicep' = {
  scope: rglogic
  name: 'module-logic'
  params: {
    env: env
    location: param.locationAlt
    staccountName: st01.outputs.stname
    aaname: aa.outputs.name
    rginfraname: rginfra.name
    runbookname: param.runbooks.adpassexp.runbookname
    tablename: st01.outputs.tablename
    clientId: param.logicapp.clientId
    clientSec: param.logicapp.clientSecret
  }
}
