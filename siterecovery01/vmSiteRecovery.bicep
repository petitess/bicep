param rsvAsrName string
param replicationPolicyId string
param vmId string
param vmName string
param osDiskId string
param primaryStId string
param recoveryRgId string
param recoveryVnetId string
param recoverySnetName string
param dataDisks array
param osDisk array = [
  {
    diskId: osDiskId
    primaryStagingAzureStorageAccountId: primaryStId
    recoveryResourceGroupId: recoveryRgId
    recoveryReplicaDiskAccountType: 'Premium_LRS'
    recoveryTargetDiskAccountType: 'Premium_LRS'
  }
]

resource replicationProtectionContainersWe 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers@2023-04-01' existing = {
  name: '${rsvAsrName}/rep-a2a-we/repcont-a2a-we'
}

resource siteRecovery 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectedItems@2023-04-01' = {
  name: '${rsvAsrName}/rep-a2a-sc/repcont-a2a-sc/${vmName}'
  properties: {
    policyId: replicationPolicyId
    providerSpecificDetails: {
      instanceType: 'A2A'
      fabricObjectId: vmId
      recoveryResourceGroupId: recoveryRgId
      recoveryContainerId: replicationProtectionContainersWe.id
      recoveryAzureNetworkId: recoveryVnetId
      recoverySubnetName: recoverySnetName
      vmManagedDisks: concat(osDisk, dataDisks)
    }
  }
}
