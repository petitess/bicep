param location string
param tags object = resourceGroup().tags
param rsvName string
param policyId string
param stRgName string
param stName string
param shares array
param stId string

resource protection 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers@2023-04-01' = {
  name: '${rsvName}/Azure/storagecontainer;Storage;${stRgName};${stName}'
  location: location
  tags: tags
  properties: {
    backupManagementType: 'AzureStorage'
    containerType: 'StorageContainer'
    sourceResourceId: stId
    acquireStorageAccountLock: 'NotAcquire'
  }
}

resource backup 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2023-04-01' = [for share in shares: if(share.backup) {
  name: 'AzureFileShare;${share.name}'
  location: location
  tags: tags
  parent: protection
  properties: {
    protectedItemType: 'AzureFileShareProtectedItem'
    policyId: policyId
    sourceResourceId: stId
  }
}]
