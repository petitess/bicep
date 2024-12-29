param name string
param location string
param publicAccess ('Disabled' | 'Enabled')
param isSftpEnabled bool
param allowedIPs array
param privateEndpoints array
param shares array
param containers array
param prodsubid string
param vnetRg string
param vnetName string
param dnsRg string
param skuName (
  | 'Premium_LRS'
  | 'Premium_ZRS'
  | 'Standard_GRS'
  | 'Standard_GZRS'
  | 'Standard_LRS'
  | 'Standard_RAGRS'
  | 'Standard_RAGZRS'
  | 'Standard_ZRS')

resource st 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    publicNetworkAccess: publicAccess
    networkAcls: {
      defaultAction: 'Deny'
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

resource file 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  name: 'default'
  parent: st
  properties: {}
}

resource share 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = [
  for share in shares: {
    name: share.name
    parent: file
    properties: {}
  }
]

resource pepR 'Microsoft.Network/privateEndpoints@2024-01-01' = [
  for pep in privateEndpoints: {
    name: 'pep-${name}-${pep.key}'
    location: location
    properties: {
      customNetworkInterfaceName: 'nic-${name}-${pep.key}'
      ipConfigurations: [
        {
          name: 'config-${pep.key}'
          properties: {
            privateIPAddress: pep.value
            groupId: pep.key
            memberName: pep.key
          }
        }
      ]
      privateLinkServiceConnections: [
        {
          name: '${st.name}-${pep.key}'
          properties: {
            privateLinkServiceId: st.id
            groupIds: [
              pep.key
            ]
          }
        }
      ]
      subnet: {
        id: resourceId(
          vnetRg,
          'Microsoft.Network/virtualNetworks/subnets',
          vnetName,
          'snet-pep'
        )
      }
    }
  }
]

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = [
  for (pep, i) in privateEndpoints: {
    name: 'default'
    parent: pepR[i]
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-${pep.key}-core-windows-net'
          properties: {
            privateDnsZoneId: resourceId(
              prodsubid,
              dnsRg,
              'Microsoft.Network/privateDnsZones',
              'privatelink.${pep.key}.${environment().suffixes.storage}'
            )
          }
        }
      ]
    }
  }
]
