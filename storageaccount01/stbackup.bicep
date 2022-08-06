targetScope = 'resourceGroup'

param policyId string
param rsvName string
param stId string
param protectionContainer string
param protectedItem string

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

resource backup 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2022-03-01' = {
  name: protectedItem
  parent: procon
  properties: {
    protectedItemType: 'AzureFileShareProtectedItem'
    policyId: policyId
    sourceResourceId: stId
  }
}

output name string = '${rsvName}/Azure/${protectionContainer}/${protectedItem}'
