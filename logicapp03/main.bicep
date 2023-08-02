targetScope = 'subscription'

param param object
param env string

var location = param.location

resource rgBlob 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: location
  tags: param.tags
  name: 'rg-logic-${env}-01'
}

module st 'st.bicep' = [for storage in param.st: {
  scope: rgBlob
  name: 'module-${storage.name}'
  params: {
    kind: storage.kind
    location: location
    name: storage.name
    sku: storage.sku
    fileShares: storage.fileShares
    containers: storage.containers
    networkAcls: storage.networkAcls
  }
}]

module logic 'logic.bicep' = {
  scope: rgBlob
  name: 'module-logic'
  params: {
    accessKey: st[0].outputs.accessKey1
    env: env
    location: location
    stName: st[0].outputs.name
  }
}
