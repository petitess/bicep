targetScope = 'subscription'

param config object
param environment string
param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location

var prefixId = toLower('${config.product}-id-${environment}-${config.location}')


resource rgId 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefixId}-01'
  location: location
  tags: union(config.tags, {
      System: 'ID'
    })
}

module id 'modules/id.bicep' = {
  scope: rgId
  name: 'id_${timestamp}'
  params: {
    location: location 
    name: 'id-${prefixId}-01'
  }
}

module rbacId 'modules/rbac.bicep' = {
  scope: rgId
  name: 'rbacId_${timestamp}'
  params: {
    principalId: id.outputs.principalId
    roles: [
      'Contributor'
    ]
  }
}
