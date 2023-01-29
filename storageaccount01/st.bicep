targetScope = 'resourceGroup'

param name string
param location string
param sku string
param kind string
param networkAcls object
param fileShares array
param containers array
param rsvName string
param policyId string

var tags = resourceGroup().tags

resource st01 'Microsoft.Storage/storageAccounts@2022-09-01' = {
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

resource files 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  parent: st01
  name: 'default'
  properties: {}
}

resource shares 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = [for fileshare in fileShares:{
  parent: files
  name: fileshare.name
  properties: fileshare.properties

}]

resource blobs 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: st01
  name: 'default'
  properties: {}
}

resource conteiner 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = [for container in containers: {
  parent: blobs
  name: container.name
  properties: {}
}]

resource protection 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers@2022-09-01-preview' = {
  name: '${rsvName}/Azure/storagecontainer;Storage;${resourceGroup().name};${st01.name}'
  tags: resourceGroup().tags
  properties: {
    backupManagementType: 'AzureStorage'
    containerType: 'StorageContainer'
    sourceResourceId: st01.id
    acquireStorageAccountLock: 'NotAcquire'
  }
}

resource backup 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2022-09-01-preview' = [for backup in fileShares: if(backup.backup) {
  name: 'AzureFileShare;${backup.name}'
  parent: protection
  properties: {
    protectedItemType: 'AzureFileShareProtectedItem'
    policyId: policyId
    sourceResourceId: st01.id
  }
}]

output stid string = st01.id
output filesharename array = [for (share, i) in fileShares:{
  filesharename: shares[i].name
}]
