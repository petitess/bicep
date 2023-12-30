targetScope = 'subscription'

param location string = deployment().location
param tags object = { ENV: 'DEV' }

resource rgFunc 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-func-prod-01'
  location: location
  tags: tags
}

resource rgRes 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-resources-prod-01'
  location: location
  tags: tags
}

module log 'modules/log.bicep' = {
  scope: rgRes
  name: 'log'
  params: {
    location: location
    name: 'log-prod-01'
  }
}

module appi 'modules/appi.bicep' = {
  scope: rgRes
  name: 'appi'
  params: {
    location: location
    WorkspaceResourceId: log.outputs.id
  }
}

module func 'modules/func.bicep' = {
  scope: rgFunc
  name: 'func'
  params: {
    location: location
    name: 'func-cons-prod-01'
    appiId: appi.outputs.id
  }
}
