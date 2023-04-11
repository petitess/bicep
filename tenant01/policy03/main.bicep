targetScope = 'tenant'

param config object
param environment string = 'prod'
param timestamp string = utcNow('yyyymmdd')
param location string = deployment().location

var prefix = toLower('${config.product}-${environment}-${config.location}')

resource mg 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'mg-sek-prod-01'
}

module policy 'policy.bicep' = {
  scope: mg
  name: 'sek_${config.product}_policy_${timestamp}'
  params: {
    location: location
  }
}
