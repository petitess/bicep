targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param networkAcls object
param privateEndpoints array
param snetId string
param dnsRgName string
param hierarchicalNamespace bool = false
param mpepName string = ''

resource st 'Microsoft.Storage/storageAccounts@2023-01-01' = {
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

resource pep 'Microsoft.Network/privateEndpoints@2023-09-01' = [
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

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = [
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

// resource mpepApprove 'Microsoft.Storage/storageAccounts/privateEndpointConnections@2023-01-01' =
//   if (!empty(mpepName)) {
//     name: !empty(mpepName) ? mpepName : 'x'
//     parent: st
//     properties: {
//       privateLinkServiceConnectionState: {
//         status: 'Approved'
//         description: 'Approved by bicep'
//       }
//     }
//   }

output id string = st.id
output name string = st.name
output api string = st.apiVersion
