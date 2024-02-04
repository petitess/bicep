targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param kind 'FileStorage' | 'StorageV2'
param networkAcls object
param shares array
param privateEndpoints ('file' | 'blob' | 'queue' | 'table' | 'web')[]
param snetId string
param dnsRgName string

resource st 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: kind == 'FileStorage' ? 'Premium_LRS' : 'Standard_LRS'
  }
  kind: kind
  properties: {
    publicNetworkAccess: 'Enabled'
    networkAcls: networkAcls
    minimumTlsVersion: 'TLS1_2'
    azureFilesIdentityBasedAuthentication: kind == 'FileStorage' ? {
      directoryServiceOptions: 'AADKERB'
      defaultSharePermission: 'StorageFileDataSmbShareContributor'
    } : null
  }
}

resource file 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  name: 'default'
  parent: st
  properties: {}
}

resource share 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = [for share in shares: {
  name: share
  parent: file
  properties: {}
}]

resource pep 'Microsoft.Network/privateEndpoints@2023-06-01' = [for pep in privateEndpoints: {
  name: 'pep-${replace(name, 'sc', pep)}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-${replace(name, 'sc', pep)}'
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
}]

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-06-01' = [for (dns, i) in privateEndpoints: {
  name: 'default'
  parent: pep[i]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-${dns}-core-windows-net'
        properties: {
          privateDnsZoneId: resourceId(dnsRgName, 'Microsoft.Network/privateDnsZones', 'privatelink.${dns}.core.windows.net')
        }
      }
    ]
  }
}]

output id string = st.id
output name string = st.name
output api string = st.apiVersion
