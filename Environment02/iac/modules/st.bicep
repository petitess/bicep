targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param sku string
param kind string
param networkAcls object
param fileShares array
param containers array

resource st 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    networkAcls: networkAcls
  }
}

resource files 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' = {
  parent: st
  name: 'default'
  properties: {}
}

resource shares 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = [for fileshare in fileShares: {
  parent: files
  name: fileshare.name
  properties: fileshare.properties
}]

resource blobs 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: st
  name: 'default'
  properties: {}
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = [for container in containers: {
  parent: blobs
  name: container.name
  properties: {
  }
}]

output id string = st.id
output name string = st.name
output api string = st.apiVersion
