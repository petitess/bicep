param name string
param location string
param tags object
param publicNetworkAccess 'Allow' | 'Deny' = 'Deny'
param dnsRg string
param ipAddress string
param ipAddressSc string
param snetPepId string = ''
param allowIps array
param rbac {
  principalId: string
  role:
    | 'AcrPull'
    | 'AcrPush'
    | 'AcrDelete'
    | 'AcrImageSigner'
    | 'AcrQuarantineReader'
    | 'AcrQuarantineWriter'
    | 'AcrQuarantineAdmin'
    | 'AcrRegistryReader'
    | 'AcrRegistryWriter'
    | 'AcrRegistryDelete'
    | 'AcrContributor'
  principalType: string?
}[] = []

resource acr 'Microsoft.ContainerRegistry/registries@2026-01-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: false
    networkRuleSet: {
      defaultAction: publicNetworkAccess
      ipRules: [
        for ip in allowIps: {
          value: ip
        }
      ]
    }
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 3
        status: 'disabled'
      }
      exportPolicy: {
        status: 'enabled'
      }
      azureADAuthenticationAsArmPolicy: {
        status: 'enabled'
      }
      softDeletePolicy: {
        retentionDays: 7
        status: 'disabled'
      }
    }
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: 'Disabled'
    metadataSearch: 'Disabled'
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2025-05-01' = {
  name: 'pep-${acr.name}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-${acr.name}'
    subnet: {
      id: snetPepId
    }
    ipConfigurations: ipAddress != ''
      ? [
          {
            name: 'config'
            properties: {
              groupId: 'registry'
              memberName: 'registry'
              privateIPAddress: ipAddress
            }
          }
          {
            name: 'config_sc'
            properties: {
              groupId: 'registry'
              memberName: 'registry_data_swedencentral'
              privateIPAddress: ipAddressSc
            }
          }
        ]
      : []
    privateLinkServiceConnections: [
      {
        name: 'plsc'
        properties: {
          privateLinkServiceId: acr.id
          groupIds: [
            'registry'
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
        name: 'azurecr'
        properties: {
          privateDnsZoneId: resourceId(dnsRg, 'Microsoft.Network/privateDnsZones', 'privatelink.azurecr.io')
        }
      }
    ]
  }
}

resource rbacR 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (r, i) in rbac: if (rbac != []) {
    name: guid(resourceGroup().id, acr.id, r.principalId, string(i))
    properties: {
      principalId: r.principalId
      roleDefinitionId: roleDefinitions(r.role).id
      principalType: r.?principalType ?? 'ServicePrincipal'
    }
  }
]
