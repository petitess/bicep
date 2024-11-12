targetScope = 'subscription'

param config object
param env string
param location string = deployment().location

var prefix = toLower('${config.product}-sys-${env}-${config.location}')
var userObjectId = ''

resource rg 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: 'rg-${prefix}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

@description('https://learn.microsoft.com/en-us/azure/azure-monitor/logs/logs-ingestion-api-overview')
module dcr 'modules/dcr.bicep' = {
  scope: rg
  name: 'dcr'
  params: {
    env: env
  }
}

@description('To make API call you need this role')
module rbac 'modules/rbac.bicep' = if (!empty(userObjectId)) {
  scope: rg
  name: 'rbac-dcr'
  params: {
    principalId: userObjectId
    roles: [
      'Monitoring Metrics Publisher'
    ]
  }
}
