targetScope = 'resourceGroup'

param rsvName string
param rsvPolicy string
param sourceId string
param protectionContainer string
param protectedItem string

var backupFabric = 'Azure'

resource backup 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2023-04-01' = {
  name: '${rsvName}/${backupFabric}/${protectionContainer}/${protectedItem}'
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: rsvPolicy
    sourceResourceId: sourceId
  }
}
