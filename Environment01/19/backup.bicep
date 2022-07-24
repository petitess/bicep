targetScope = 'resourceGroup'

param location string
param policyId string
param sourceResourceId string
param rsvName string
param protectionContainer string
param protectedItem string

var backupFabric = 'Azure'
var tags = resourceGroup().tags

resource backup 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2022-02-01' = {
  name: '${rsvName}/${backupFabric}/${protectionContainer}/${protectedItem}'
  location: location
  tags: tags
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: policyId
    sourceResourceId: sourceResourceId
  }
}
