param name string
param location string
param tags object = resourceGroup().tags
@allowed([ 'Disabled', 'Enabled' ])
param publicNetworkAccess string
param sku string
param containersCount int
param shares array
param snetId string

var groupIds = [
  'blob'
  'file'
]

resource st 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: publicNetworkAccess == 'Disabled' ? 'Deny' : 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: st
  properties: {

  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for (cont, i) in range(0, containersCount): {
  name: 'container${100 + 100 * i}'
  parent: blob
  properties: {}
}]

resource file 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  name: 'default'
  parent: st
  properties: {}
}

resource share 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = [for share in shares: {
  name: share.name
  parent: file
  properties: {}
}]

resource pep 'Microsoft.Network/privateEndpoints@2023-04-01' = [for pep in groupIds: if (publicNetworkAccess == 'Disabled') {
  name: '${name}-${pep}-pep'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: '${name}-${pep}-nic'
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

output id string = st.id
