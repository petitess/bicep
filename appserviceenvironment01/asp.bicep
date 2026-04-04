targetScope = 'resourceGroup'

param name string
param location string = resourceGroup().location
param kind (
  | 'app'
  | 'app,linux'
  | 'app,linux,container'
  | 'hyperV'
  | 'linux'
  | 'app,container,windows'
  | 'app,linux,kubernetes'
  | 'app,linux,container,kubernetes'
  | 'functionapp'
  | 'functionapp,linux'
  | 'functionapp,linux,container,kubernetes'
  | 'functionapp,linux,kubernetes')

param sku { name: 'P0v3' | 'I1v2' | 'I1mV2', tier: 'Premium0V3' | 'IsolatedV2' | 'IsolatedMV2' }
param keyVaultId string?
param keyVaultSecretName string?
param aseId string = ''

var tags = resourceGroup().tags

resource asp 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  sku: sku
  properties: {
    reserved: contains(kind, 'linux')
    hostingEnvironmentProfile: aseId == '' ? null : {
       id: aseId
    }
  }
}

resource cert 'Microsoft.Web/certificates@2025-03-01' = if(!empty(keyVaultId) && !empty(keyVaultSecretName)) {
  name: '${asp.name}-cert'
  location: resourceGroup().location
  tags: resourceGroup().tags
  properties: {
    keyVaultId: keyVaultId
    keyVaultSecretName: keyVaultSecretName
  }
}

output id string = asp.id
