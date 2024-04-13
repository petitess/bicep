targetScope = 'subscription'

param location string
param env string
param tags object

var affix = toLower('${tags.Application}-${tags.Environment}')
var vmPrincipalId = ''

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  location: location
  tags: tags
  name: 'rg-${affix}-01'
}

resource rgLogic 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  location: location
  tags: union(
    tags,
    {
      Application: 'AD Password Expiration'
    }
  )
  name: 'rg-logic-${affix}-01'
}

module aa 'aa.bicep' = {
  scope: rg
  name: 'aa'
  params: {
    location: location
    name: 'aa-${affix}-01'
  }
}

module rbacAa 'rbac.bicep' = {
  name: 'rbac_aa'
  params: {
    principalId: aa.outputs.principalId
    roles: [
      'Virtual Machine Contributor'
    ]
  }
}

module id 'id.bicep' = {
  scope: rg
  name: 'id'
  params: {
    location: location
    name: 'id-${affix}-01'
  }
}

module rbacId 'rbac.bicep' = {
  name: 'rbac_id'
  params: {
    principalId: id.outputs.principalId
    roles: [
      'Contributor'
    ]
  }
}

module script 'script.bicep' = {
  scope: rg
  name: 'script'
  params: {
    idId: id.outputs.id
    location: location
    name: 'ds-ad-pass-${affix}-01'
    aaName: aa.outputs.name
    aaRgName: rg.name
  }
}

module st 'st.bicep' = {
  scope: rg
  name: 'st'
  params: {
    kind: 'StorageV2'
    location: location
    name: 'stlogicpass${env}01'
    sku: 'Standard_LRS'
  }
}

module logic 'logic.bicep' = {
  scope: rgLogic
  name: 'logic'
  params: {
    env: env
    location: location
    aaName: aa.outputs.name
    rgAaName: rg.name
    stName: st.outputs.name
    tableName: st.outputs.tableName
  }
}

module rbacLogic 'rbac.bicep' = {
  name: 'rbac_loguc'
  params: {
    principalId: logic.outputs.principalId
    roles: [
      'Storage Table Data Contributor'
      'Contributor'
    ]
  }
}

@description('To be able to run AdPasswordExpirationEntra.ps1')
module rbacVm 'rbac.bicep' =
  if (!empty(vmPrincipalId)) {
    name: 'rbac_vm'
    params: {
      principalId: vmPrincipalId
      roles: [
        'Storage Table Data Contributor'
      ]
    }
  }
