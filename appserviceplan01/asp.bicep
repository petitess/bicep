targetScope = 'resourceGroup'

param name string
param location string = resourceGroup().location
param kind (
  | 'app'
  | 'app,linux'
  | 'app,linux,container'
  | 'hyperV'
  | 'app,container,windows'
  | 'app,linux,kubernetes'
  | 'app,linux,container,kubernetes'
  | 'functionapp'
  | 'functionapp,linux'
  | 'functionapp,linux,container,kubernetes'
  | 'functionapp,linux,kubernetes')

param sku { name: string, tier: string }
param keyVaultId string?
param keyVaultSecretName string?

var tags = resourceGroup().tags

resource asp 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  sku: sku
  properties: {}
}

resource cert 'Microsoft.Web/certificates@2024-04-01' = if(!empty(keyVaultId) && !empty(keyVaultSecretName)) {
  name: '${asp.name}-cert'
  location: resourceGroup().location
  tags: resourceGroup().tags
  properties: {
    keyVaultId: keyVaultId
    keyVaultSecretName: keyVaultSecretName
  }
}


output id string = asp.id
