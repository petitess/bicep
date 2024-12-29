param name string
param kvName string
param pass string

resource secret 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  name: '${kvName}/${name}'
  properties: {
    value: pass
  }
}
