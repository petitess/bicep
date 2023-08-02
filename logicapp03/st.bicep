targetScope = 'resourceGroup'

param name string
param location string
param sku string
param kind string
param networkAcls object
param fileShares array
param containers array

var tags = resourceGroup().tags

resource st 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: name
  tags: tags
  location: location
  sku: {
    name:  sku
  }
  kind: kind
  properties: {
    networkAcls:  networkAcls
    isSftpEnabled: true
    isHnsEnabled: true
  }
}

resource files 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  parent: st
  name: 'default'
  properties: {}
}

resource shares 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = [for fileshare in fileShares:{
  parent: files
  name: fileshare.name
  properties: fileshare.properties

}]

resource blobs 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: st
  name: 'default'
  properties: {}
}

resource conteiner 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = [for container in containers: {
  parent: blobs
  name: container.name
  properties: {}
}]

output name string = st.name
output id string = st.id
output filesharename array = [for (share, i) in fileShares:{
  filesharename: shares[i].name
}]
output accessKey1 string = st.listKeys().keys[0].value
