targetScope = 'resourceGroup'

param name string
param location string
param contributor string
param keyvaultadmin string
@description('UTC, Date dd/mm/yyy')
param basedate string = utcNow('d')
@description('W. Europe Standard Time, hh:mm')
param basetime string = dateTimeAdd(utcNow(), 'PT2H', 't')

var tags = resourceGroup().tags

resource aa 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

module rbac 'rbac.bicep' = {
  scope: subscription()
  name: 'module-${name}-rbac'
  params: {
    contributor: contributor
    keyvaultadmin: keyvaultadmin
    principalId: aa.identity.principalId
  }
}

output id string = aa.id
output name string = aa.name
output basedate string = basedate
output basetime string = basetime
