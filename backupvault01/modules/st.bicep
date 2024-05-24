param name string
param location string
param tags object = resourceGroup().tags
param networkAcls object
param privateEndpoints ('blob' | 'file' | 'table' | 'queue' | 'web' | 'dfs')[]
param snetId string
param dnsRgName string
param hierarchicalNamespace bool = false
param containers ({ name: string, immutability: bool, backup: bool })[]
param vaultName string
param vaultRgName string
param blobBackupPolicyId string

resource st 'Microsoft.Storage/storageAccounts@2023-04-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: networkAcls
    isHnsEnabled: hierarchicalNamespace
    minimumTlsVersion: 'TLS1_2'
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2023-04-01' = {
  name: 'default'
  parent: st
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: false
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-04-01' = [
  for c in containers: {
    name: c.name
    parent: blob
    properties: {}
  }
]

resource immutabilityR 'Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies@2023-04-01' = [
  for (policy, i) in containers: if (policy.immutability) {
    name: 'default'
    parent: container[i]
    properties: {
      allowProtectedAppendWritesAll: false
      allowProtectedAppendWrites: false
      immutabilityPeriodSinceCreationInDays: 14
    }
  }
]

module backupInstance 'bvault-instance.bicep' = {
  name: name
  scope: resourceGroup(vaultRgName)
  params: {
    name: name
    policyId: blobBackupPolicyId
    resourceId: st.id
    vaultName: vaultName
    containersList: [for c in filter(containers, c => c.backup): c.name]
    datasourceType: 'Microsoft.Storage/storageAccounts/blobServices'
    resourceType: 'Microsoft.Storage/storageAccounts'
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2023-11-01' = [
  for pep in privateEndpoints: {
    name: 'pep-${substring(name, 0, length(name) - 2)}${pep}${substring(name, length(name) - 2, 2)}'
    location: location
    tags: tags
    properties: {
      customNetworkInterfaceName: 'nic-pep-${substring(name, 0, length(name) - 2)}${pep}${substring(name, length(name) - 2, 2)}'
      privateLinkServiceConnections: [
        {
          name: '${st.name}-${pep}'
          properties: {
            privateLinkServiceId: st.id
            groupIds: [
              pep
            ]
          }
        }
      ]
      subnet: {
        id: snetId
      }
    }
  }
]

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = [
  for (dns, i) in privateEndpoints: {
    name: 'default'
    parent: pep[i]
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-${dns}-core-windows-net'
          properties: {
            privateDnsZoneId: resourceId(
              dnsRgName,
              'Microsoft.Network/privateDnsZones',
              'privatelink.${dns}.core.windows.net'
            )
          }
        }
      ]
    }
  }
]

output id string = st.id
output name string = st.name
output api string = st.apiVersion
output defaultEndpointsProtocol string = 'DefaultEndpointsProtocol=https;AccountName=${st.name};AccountKey=${st.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
