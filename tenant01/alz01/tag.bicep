targetScope = 'subscription'

param tags object

resource tag 'Microsoft.Resources/tags@2022-09-01' = {
  name: 'default'
  properties: {
    tags: tags
  }
}
