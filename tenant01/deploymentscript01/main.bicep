targetScope = 'tenant'

param config object
param environment string = 'prod'
param timestamp string = utcNow('yyyymmdd')
param location string = deployment().location

var prefix = toLower('${config.product}-${environment}-${config.location}')
var platformSubscription = {
  name: 'Azure subscription 1'
  id: 'xxxxxxx-e3df-4ea1-b956-xxxxx'
}

module rgPlatform 'rg.bicep' = {
  scope: subscription(platformSubscription.id)
  name: 'sek_${config.product}_rg_${timestamp}'
  params: {
    location: location
    prefix: prefix
  }
}

module script 'script.bicep' = {
  scope: resourceGroup(platformSubscription.id, 'rg-${prefix}-01')
  name: 'sek_${config.product}_script_${timestamp}'
  dependsOn: [rgPlatform]
  params: {
    location: location
    prefix: prefix
    groupPrefix: config.groupPrefix
    tags: config.tags
  }
}
