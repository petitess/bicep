targetScope = 'subscription'

param config object
param env string
param location string = deployment().location

var prefix = toLower('${config.product}-sys-${env}-${config.location}')

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
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
    rbac: [
      {
        principalId: '123-67c5c5f224a1'
        role: 'Monitoring Metrics Publisher'
        principalType: 'User'
      }
    ]
  }
}
