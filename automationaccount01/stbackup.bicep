targetScope = 'resourceGroup'

param policyId string
param rsvName string
param stId string
param protectionContainer string
param fileShares array

resource procon 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers@2022-03-01' = {
  name: '${rsvName}/Azure/${protectionContainer}'
  tags: resourceGroup().tags
  properties: {
    backupManagementType: 'AzureStorage'
    containerType: 'StorageContainer'
    sourceResourceId: stId
    acquireStorageAccountLock: 'NotAcquire'
  }
}

resource backup 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2022-03-01' = [for fileShare in fileShares: if (fileShare.backup) {
  name: 'AzureFileShare;${fileShare.name}'
  parent: procon
  properties: {
    protectedItemType: 'AzureFileShareProtectedItem'
    policyId: policyId
    sourceResourceId: stId
  }
}]


