param name string
param sku string
param kind 'linux' | 'app'

resource asp 'Microsoft.Web/serverfarms@2023-12-01' = {
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

output id string = asp.id
