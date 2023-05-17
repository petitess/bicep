targetScope = 'subscription'

param config object
param environment string = 'test'
param timestamp string = utcNow('ddMMyyyy_HHmm')
param location string = deployment().location

var prefixSpoke = toLower('${config.product}-spoke-${environment}-${config.location}')

resource tags 'Microsoft.Resources/tags@2022-09-01' = {
  name: 'default'
  properties: {
    tags: config.tags
  }
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${prefixSpoke}-01'
  location: location
  tags: union(config.tags, {
      System: 'Spoke'
    })
}

module pim 'pim.bicep' = { 
  scope: rg
  name: 'pim_${timestamp}'
  params: {
    location: location
    name: 'script-governance-01'
  }
}
