param name string
param kvName string
param pass string

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: '${kvName}/${name}'
  properties: {
    value: pass
  }
}
