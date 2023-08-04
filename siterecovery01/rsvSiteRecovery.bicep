targetScope = 'resourceGroup'

param name string
param secondarylocation string
param primaryLocation string
param tags object = resourceGroup().tags
param asrVnetId string
param vnetId string

resource rsv 'Microsoft.RecoveryServices/vaults@2023-04-01' = {
  name: name
  location: secondarylocation
  tags: tags
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    restoreSettings: {
      crossSubscriptionRestoreSettings: {
        crossSubscriptionRestoreState: 'Enabled'
      }
    }
  }
}

resource replicationPolicy 'Microsoft.RecoveryServices/vaults/replicationPolicies@2023-04-01' = {
  parent: rsv
  name: 'ReplicationPolicy01'
  properties: {
    providerSpecificInput: {
      instanceType: 'A2A'
      multiVmSyncStatus: 'Enable'
      appConsistentFrequencyInMinutes: 120
      recoveryPointHistory: 5760
      crashConsistentFrequencyInMinutes: 5
    }
  }
}

resource replicationFabricsWe 'Microsoft.RecoveryServices/vaults/replicationFabrics@2023-04-01' = {
  name: 'rep-a2a-we'
  parent: rsv
  properties: {
    customDetails: {
      instanceType: 'Azure'
      location: secondarylocation
    }
  }
}

resource replicationFabricsSc 'Microsoft.RecoveryServices/vaults/replicationFabrics@2023-04-01' = {
  name: 'rep-a2a-sc'
  parent: rsv
  properties: {
    customDetails: {
      instanceType: 'Azure'
      location: primaryLocation
    }
  }
}

resource replicationProtectionContainersWe 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers@2023-04-01' = {
  name: 'repcont-a2a-we'
  parent: replicationFabricsWe
  properties: {
    providerSpecificInput: [
      {
        instanceType: 'A2A'
      }
    ]
  }
}

resource replicationProtectionContainersSc 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers@2023-04-01' = {
  name: 'repcont-a2a-sc'
  parent: replicationFabricsSc
  properties: {
    providerSpecificInput: [
      {
        instanceType: 'A2A'
      }
    ]
  }
}

resource mappingSc 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectionContainerMappings@2023-04-01' = {
  name: 'mapping-a2a-sc'
  parent: replicationProtectionContainersSc
  properties: {
    policyId: replicationPolicy.id
    targetProtectionContainerId: replicationProtectionContainersWe.id
    providerSpecificInput: {
      instanceType: 'A2A'
      automationAccountArmId: aa.id
      automationAccountAuthenticationType: 'SystemAssignedIdentity'
      agentAutoUpdateStatus: 'Disabled'
    }
  }
}

resource mappingWe 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectionContainerMappings@2023-04-01' = {
  name: 'mapping-a2a-we'
  parent: replicationProtectionContainersWe
  properties: {
    policyId: replicationPolicy.id
    targetProtectionContainerId: replicationProtectionContainersSc.id
    providerSpecificInput: {
      instanceType: 'A2A'
      automationAccountArmId: aa.id
      automationAccountAuthenticationType: 'SystemAssignedIdentity'
      agentAutoUpdateStatus: 'Disabled'
    }
  }
}

resource replicationNetworksSc 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationNetworks@2023-04-01' existing = {
  name: 'azureNetwork'
  parent: replicationFabricsSc
}

resource replicationNetworksWe 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationNetworks@2023-04-01' existing = {
  name: 'azureNetwork'
  parent: replicationFabricsWe
}

resource NetworkMappingsSc 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationNetworks/replicationNetworkMappings@2023-04-01' = {
  name: 'sc-we-vnet'
  parent: replicationNetworksSc
  properties: {
    recoveryNetworkId: asrVnetId
    recoveryFabricName: replicationFabricsWe.name
    fabricSpecificDetails: {
      instanceType: 'AzureToAzure'
      primaryNetworkId: vnetId
    }
  }
}

resource NetworkMappingsWe 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationNetworks/replicationNetworkMappings@2023-04-01' = {
  name: 'we-sc-vnet'
  parent: replicationNetworksWe
  properties: {
    recoveryNetworkId: vnetId
    recoveryFabricName: replicationFabricsSc.name
    fabricSpecificDetails: {
      instanceType: 'AzureToAzure'
      primaryNetworkId: asrVnetId
    }
  }
}

resource stAsrP 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'stsiterecovery${take(uniqueString(resourceGroup().name), 5)}sc01'
  location: primaryLocation
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

resource stAsrS 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'stsiterecovery${take(uniqueString(resourceGroup().name), 5)}we01'
  location: secondarylocation
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

resource aa 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: replace(name, 'rsv', 'aa')
  location: secondarylocation
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

output id string = rsv.id
output name string = rsv.name
output replicationPolicy string = replicationPolicy.id
output primaryStId string = stAsrP.id
