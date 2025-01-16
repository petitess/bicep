param name string
param sku 'FC1' | 'P0v3'
param kind 'linux' | 'app'
param keyVaultId string?
param keyVaultSecretName string?

resource asp 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: name
  tags: resourceGroup().tags
  location: resourceGroup().location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    reserved: kind == 'linux' ? true : false
  }
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
//output thumbprint01 string = cert.properties.thumbprint
