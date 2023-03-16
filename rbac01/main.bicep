targetScope = 'subscription'

param config object
param environment string = 'dev'
param timestamp string = utcNow('ddMMyyyy')
param location string = deployment().location

var prefix = toLower('${config.product}-waf-${environment}-${config.location}')

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${prefix}-02'
  location: location
  tags: union(config.tags, {
      System: 'Spoke'
    })
}

module id 'id.bicep' = {
  scope: rg
  name: 'id_${timestamp}'
  params: {
    name: 'id-${prefix}-01'
    location: location
  }
}

module rbacId 'rbac.bicep' = {
  name: 'rbacId_${timestamp}'
  params: {
    principalId: id.outputs.principalId
    roles: [
      'Contributor' 
      'Reader'
    ]
  }
}
