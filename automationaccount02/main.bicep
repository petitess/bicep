targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

resource rginfra 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-sc-01'
}

resource rgAlt 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${affix}-we-01'
  location: param.locationAlt
  tags: param.tags
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


module rsv 'rsv.bicep' = {
  scope: rginfra
  name: 'module-${affix}-rsv'
  params: {
    daysOfTheWeek: param.rsv.daysOfTheWeek
    location: param.location
    name: 'rsv-${affix}-01'
    sku: param.rsv.sku
    retentionDays: param.rsv.retentionDays
    retentionTimes: param.rsv.retentionTimes
    retentionWeeks: param.rsv.retentionWeeks
    scheduleRunTimes: param.rsv.scheduleRunTimes
    timeZone: param.rsv.timeZone
  }
}

module script 'script.bicep' = {
  scope: rgAlt
  name: 'module-${affix}-script-infra'
  params: {
    idId: id.outputs.id
    rsvname: id.outputs.name
    location: rgAlt.location
    name: affix
    param: param
    aaname: aa.outputs.name
    aargname: rginfra.name
  }
}
 