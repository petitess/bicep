param name string
param location string
param publicAccess ('Disabled' | 'Enabled')
param isSftpEnabled bool
param allowedIPs array
param privateEndpoints array
param shares array
param containers array
param snetPepId string
param privateDnsZoneRg string
param skuName (
  | 'Premium_LRS'
  | 'Premium_ZRS'
  | 'Standard_GRS'
  | 'Standard_GZRS'
  | 'Standard_LRS'
  | 'Standard_RAGRS'
  | 'Standard_RAGZRS'
  | 'Standard_ZRS')
param rbac ({
  role: (
    | 'Storage Queue Data Contributor'
    | 'Storage Table Data Contributor'
    | 'Storage Blob Data Contributor'
    | 'Storage File Data Privileged Contributor')
  principalId: string
})[] = []

var rolesList = {
  'Storage Queue Data Contributor': '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
  'Storage Table Data Contributor': '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
  'Storage Blob Data Contributor': 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  'Storage File Data Privileged Contributor': '69566ab7-960f-475b-8e7c-b3118f30c6bd'
}

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
    defaultToOAuthAuthentication: false
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

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = [
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

resource pepR 'Microsoft.Network/privateEndpoints@2024-05-01' = [
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
        id: snetPepId
      }
    }
  }
]

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = [
  for (pep, i) in privateEndpoints: {
    name: 'default'
    parent: pepR[i]
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-${pep.key}-core-windows-net'
          properties: {
            privateDnsZoneId: resourceId(
              subscription().subscriptionId,
              privateDnsZoneRg,
              'Microsoft.Network/privateDnsZones',
              'privatelink.${pep.key}.${environment().suffixes.storage}'
            )
          }
        }
      ]
    }
  }
]

resource rbacR 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (r, i) in rbac: if (rbac != []) {
    name: guid(resourceGroup().id, r.principalId, r.role, string(i))
    properties: {
      principalId: r.principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleAssignments', rolesList[r.role])
      principalType: 'ServicePrincipal'
    }
  }
]

output defaultEndpointsProtocol string = 'DefaultEndpointsProtocol=https;AccountName=${st.name};AccountKey=${st.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
