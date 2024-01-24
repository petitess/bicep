param storageAccountName string
param location string
param keyvaultname string
param connectionBlobContainer string
param subnetId string
param pdnszRg string

resource st 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: false
    publicNetworkAccess: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
  }
  sku: {
    name: 'Standard_LRS'
  }
  resource service 'blobServices' = {
    name: 'default'

    resource blobContainer 'containers' = {
      name: 'standardfiles'
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' existing = { name: keyvaultname }

resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: connectionBlobContainer
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${st.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-11-01' = {
  name: 'pep-${storageAccountName}'
  location: location
  properties: {
    customNetworkInterfaceName: 'nic-${storageAccountName}'
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: storageAccountName
        properties: {
          privateLinkServiceId: st.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }

  resource privateDNSZoneGroup 'privateDnsZoneGroups@2022-09-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-blob-core-windows-net'
          properties: {
            privateDnsZoneId: resourceId(pdnszRg, 'Microsoft.Network/privateDnsZones', 'privatelink.blob.${environment().suffixes.storage}')
          }
        }
      ]
    }
  }
}
