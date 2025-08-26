param name string
param snetId string
param pdnszId string
param rbac (
  | 'Storage Queue Data Contributor'
  | 'Storage Table Data Contributor'
  | 'Storage Blob Data Contributor'
  | 'Storage File Data Privileged Contributor')[] = []

var rolesList = {
  'Storage Queue Data Contributor': '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
  'Storage Table Data Contributor': '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
  'Storage Blob Data Contributor': 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  'Storage File Data Privileged Contributor': '69566ab7-960f-475b-8e7c-b3118f30c6bd'
}

resource trsl 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: name
  location: resourceGroup().location
  sku: {
    name: 'S1'
  }
  kind: 'TextTranslation'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: name
    networkAcls: {
      defaultAction: 'Allow'
    }
    publicNetworkAccess: 'Enabled'
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2024-07-01' = {
  name: 'pep-${name}'
  location: resourceGroup().location
  properties: {
    customNetworkInterfaceName: 'nic-pep-${name}'
    privateLinkServiceConnections: [
      {
        name: 'pl-connection'
        properties: {
          privateLinkServiceId: trsl.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
    subnet: {
      id: snetId
    }
  }
}

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-07-01' = {
  name: 'default'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-cognitiveservices-azure-com'
        properties: {
          privateDnsZoneId: pdnszId
        }
      }
    ]
  }
}

resource rbacR 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (r, i) in rbac: if (rbac != []) {
    name: guid(resourceGroup().id, trsl.id, r, string(i))
    properties: {
      principalId: trsl.identity.principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleAssignments', rolesList[r])
      principalType: 'ServicePrincipal'
    }
  }
]
