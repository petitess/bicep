targetScope = 'resourceGroup'

param name string
param location string
param sku string
param kind string
param networkAcls object
param fileShares array
param containers array
param rsvName string
param rsvRg string
param policyId string

var tags = resourceGroup().tags

resource st01 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: name
  tags: tags
  location: location
  sku: {
    name:  sku
  }
  kind: kind
  properties: {
    networkAcls:  networkAcls
  }
}

resource files 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' = {
  parent: st01
  name: 'default'
  properties: {}
}

resource shares 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = [for fileshare in fileShares:{
  parent: files
  name: fileshare.name
  properties: fileshare.properties

}]

resource blobs 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: st01
  name: 'default'
  properties: {}
}

resource conteiner 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = [for container in containers: {
  parent: blobs
  name: container.name
  properties: {}
}]

module backup 'stbackup.bicep' = [for fileShare in fileShares: if (fileShare.backup) {
  scope: resourceGroup(rsvRg)
  name: 'module-${fileShare.name}-backup'
  params: {
    protectedItem: 'AzureFileShare;${fileShare.name}'
    protectionContainer: 'storagecontainer;Storage;${resourceGroup().name};${st01.name}'
    rsvName: rsvName
    policyId: policyId
    stId: st01.id

  }
}] 

output stid string = st01.id
// output filesharename array = [for (share, i) in fileShares:{
//   filesharename: share[i].id
// }]
