targetScope = 'resourceGroup'

param name string
// param env string
param location string
param publicAccess ('Disabled' | 'Enabled')
param isSftpEnabled bool = false
param allowedIPs array = [] 
// param privateEndpoints array
// param shares array
// param containers array
// param prodsubid string
param skuName (
  | 'Premium_LRS'
  | 'Premium_ZRS'
  | 'Standard_GRS'
  | 'Standard_GZRS'
  | 'Standard_LRS'
  | 'Standard_RAGRS'
  | 'Standard_RAGZRS'
  | 'Standard_ZRS') = 'Standard_LRS'
param containers array

resource st 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: name
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    publicNetworkAccess: publicAccess
    allowSharedKeyAccess: false
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
      ipRules: [
        for rule in allowedIPs: {
          value: rule
          action: 'Allow'
        }
      ]
    }
    isHnsEnabled: isSftpEnabled
    isSftpEnabled: isSftpEnabled
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    defaultToOAuthAuthentication: true
  }
}

resource blobservice 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  name: 'default'
  parent: st
  properties: {
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [
  for (c, i) in containers: {
    name: c
    parent: blobservice
    properties: {}
  }
]

output id string = st.id
