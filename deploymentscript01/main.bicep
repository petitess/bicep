targetScope = 'subscription'

param env string
param param object
param appGroups array
param identities array

var location = param.location
var affix = toLower('groups-${param.tags.Environment}')
var group = toObject(array(script.outputs.groups), outputs => outputs.name)

resource rgInfra 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

resource rgId 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-id-${env}-01'
}

module mId 'id.bicep' = [for id in identities: {
  name: id.name
  scope: rgId
  params: {
    name: id.name
    location: location
    tags: param.tags
  }
}]

module script 'script.bicep' = {
  scope: rgInfra
  name: 'module-groups'
  params: {
    location: param.location
    affix: affix
    appGroups: appGroups
    managedIds: [for (id, i) in identities: {
      name: id.name
      objectId: mId[i].outputs.principalId
      groupName: id.groupName
    }]
    tags: union(param.tags, {
        Application: 'Azure AD'
      })
  }
}

output groupId string = group['grp-rbac-app-itglue-${env}'].objectId
output mIdPrincipal array = [for (id, i) in identities: {
  name: id.name
  objectId: mId[i].outputs.principalId
  groupName: id.groupName
}]
