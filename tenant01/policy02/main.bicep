targetScope = 'tenant'

param config object
param environment string = 'prod'
param timestamp string = utcNow('yyyymmdd')
param location string = deployment().location

var prefix = toLower('${config.product}-${environment}-${config.location}')
var platformSubscription = {
  name: 'Azure subscription 1'
  id: 'xxx-e3df-4ea1-b956-xxx'
}

resource mg 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'mg-sek-prod-01'
}

module rgPlatform 'rg.bicep' = {
  scope: subscription(platformSubscription.id)
  name: 'sek_${config.product}_rg_${timestamp}'
  params: {
    location: location
    prefix: prefix
    tags: config.tags
  }
}

module script 'id.bicep' = {
  scope: resourceGroup(platformSubscription.id, 'rg-${prefix}-01')
  name: 'sek_${config.product}_script_${timestamp}'
  dependsOn: [ rgPlatform ]
  params: {
    location: location
    prefix: prefix
    tags: config.tags
  }
}

module policy 'policy.bicep' = {
  scope: mg
  name: 'sek_${config.product}_policy_${timestamp}'
  params: {
    location: location
  }
}
