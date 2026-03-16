param name string
param location string
param snetPep string
param ipAddress1 string
param ipAddress2 string
param ipAddress3 string
param dnsRg string
param stId string
param isolationMode resourceInput<'Microsoft.CognitiveServices/accounts/managednetworks@2025-10-01-preview'>.properties.managedNetwork.isolationMode = 'AllowOnlyApprovedOutbound'

resource aif 'Microsoft.CognitiveServices/accounts@2025-10-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    apiProperties: {}
    customSubDomainName: name
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    allowProjectManagement: true
    defaultProject: 'proj-function'
    associatedProjects: [
      'proj-function'
    ]
    publicNetworkAccess: 'Disabled'
    storedCompletionsDisabled: false
  }
}

resource proj 'Microsoft.CognitiveServices/accounts/projects@2025-10-01-preview' = {
  parent: aif
  name: 'proj-function'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    description: 'Default project created with the resource'
    displayName: 'proj-function'
  }
}

resource model 'Microsoft.CognitiveServices/accounts/deployments@2025-10-01-preview' = {
  parent: aif
  name: 'gpt-5.3-chat-lab'
  sku: {
    name: 'GlobalStandard'
    capacity: 500
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-5.3-chat'
      version: '2026-03-03'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    currentCapacity: 500
    raiPolicyName: 'Microsoft.DefaultV2'
  }
}
@description('Preview')
resource managedNetwork 'Microsoft.CognitiveServices/accounts/managednetworks@2025-10-01-preview' = if(false) {
  parent: aif
  name: 'default'
  properties: {
    managedNetwork: {
      isolationMode: isolationMode
      managedNetworkKind: 'V2'
      // firewallSku: isolationMode == 'AllowOnlyApprovedOutbound' ? 'Standard' : null
    }
  }
}
@description('Preview')
resource storageOutboundRule 'Microsoft.CognitiveServices/accounts/managednetworks/outboundRules@2025-10-01-preview' = {
  parent: managedNetwork
  name: 'storage-outbound-rule'
  properties: {
    type: 'PrivateEndpoint'
    destination: {
      serviceResourceId: stId
      subresourceTarget: 'blob'
      sparkEnabled: false
      sparkStatus: 'Inactive'
    }
    category: 'UserDefined'
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2025-05-01' = {
  name: 'pep-${aif.name}'
  location: location
  dependsOn: [
    proj
    model
  ]
  properties: {
    customNetworkInterfaceName: 'nic-${aif.name}'
    subnet: {
      id: snetPep
    }
    ipConfigurations: [
      {
        name: 'config-cognitiveservices'
        properties: {
          groupId: 'account'
          memberName: 'default'
          privateIPAddress: ipAddress1
        }
      }
      {
        name: 'config-openai'
        properties: {
          groupId: 'account'
          memberName: 'secondary'
          privateIPAddress: ipAddress2
        }
      }
      {
        name: 'config-services-ai'
        properties: {
          groupId: 'account'
          memberName: 'third'
          privateIPAddress: ipAddress3
        }
      }
    ]
    privateLinkServiceConnections: [
      {
        name: 'plsc'
        properties: {
          privateLinkServiceId: aif.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
  }
}

resource pdnszg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-05-01' = {
  name: 'default'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'cognitiveservices'
        properties: {
          privateDnsZoneId: resourceId(
            dnsRg,
            'Microsoft.Network/privateDnsZones',
            'privatelink.cognitiveservices.azure.com'
          )
        }
      }
      {
        name: 'openai'
        properties: {
          privateDnsZoneId: resourceId(dnsRg, 'Microsoft.Network/privateDnsZones', 'privatelink.openai.azure.com')
        }
      }
      {
        name: 'services-ai'
        properties: {
          privateDnsZoneId: resourceId(dnsRg, 'Microsoft.Network/privateDnsZones', 'privatelink.services.ai.azure.com')
        }
      }
    ]
  }
}

output key1 string = aif.listKeys().key1
