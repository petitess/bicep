targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${affix}-sc-01'
  location: param.location
  tags: param.tags
}

module kv 'kv.bicep' = {
  scope: rg
  name: 'module-${affix}-kv'
  params: {
    location: param.location
    name: 'kv-comp-${affix}-02'
    sku: param.kv.sku
    enabledForDeployment: param.kv.enabledForDeployment
    enabledForDiskEncryption: param.kv.enabledForDiskEncryption
    enabledForTemplateDeployment: param.kv.enabledForTemplateDeployment
    enableRbacAuthorization: param.kv.enableRbacAuthorization
  }
}

module id 'id.bicep' = {
  scope: rg
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
    keyvaultadmin: param.id.keyvaultadmin
    contributor: param.id.contributor
  }
}

resource rgAlt 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${affix}-we-01'
  location: param.locationAlt
  tags: param.tags
}

module vmScript 'vmScript.bicep' = {
  scope: rgAlt
  name: 'module-${affix}-script'
  params: {
    kvName: kv.outputs.name
    location: rgAlt.location
    name: 'vmScript-${affix}-01'
    vm: param.vm
    vmadc: param.vmadc
    vmctx: param.vmctx
    idId: id.outputs.id
    idName: id.outputs.name
  }
}



