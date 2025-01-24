param name string
param kind 'functionapp,linux' | 'functionapp'
param funcAppServicePlanId string
param snetOutboundId string
param snetPepId string
param appiConnectionString string?
param defaultEndpointsProtocol string
param appSettings ({ name: string, value: string })[] = []
param privateEndpoints ({ sites: string?, 'sites-stage': string? })
param privateDnsZoneId string
param customDomain string?
param isFlexConsumptionTier bool
param storageName string
param storageContainerName string
param slot ({
  name: ('stage')?
  appSettings: ({ name: string, value: string })[]?
  customDomain: string?
  authEnabled: bool?
}) = {}
param thumbprint string?
param auth ({ authClientId: string?, authAllowedAudience: string? })

param rbac ({
  role: ('Website Contributor' | 'Reader' | 'Contributor' | 'Storage Blob Data Contributor')
  principalId: string
})[]
var rolesList = {
  'Website Contributor': 'Website Contributor'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  'Storage Blob Data Contributor': 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

var funcAppSettings = [
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appiConnectionString
  }
  {
    name: 'AzureWebJobsDashboard'
    value: defaultEndpointsProtocol
  }
  {
    name: 'AzureWebJobsStorage'
    value: defaultEndpointsProtocol
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: 'dotnet-isolated'
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: defaultEndpointsProtocol
  }
  {
    name: 'WEBSITE_CONTENTOVERVNET'
    value: '1'
  }
  {
    name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
    value: '1'
  }
  {
    name: 'WEBSITE_RUN_FROM_PACKAGE'
    value: kind == 'functionapp,linux' ? '1' : '0'
  }
  {
    name: 'WEBSITE_CONTENTSHARE'
    value: storageContainerName
  }
  {
    name: 'AzureWebJobsStorage__accountName' //FOR RBAC
    value: storageName
  }
]

var funcAppSettingsFlex = [
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appiConnectionString
  }
  {
    name: 'AzureWebJobsStorage'
    value: defaultEndpointsProtocol
  }
]

resource func 'Microsoft.Web/sites@2024-04-01' = {
  name: name
  location: resourceGroup().location
  tags: resourceGroup().tags
  kind: kind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: funcAppServicePlanId
    httpsOnly: true
    reserved: kind == 'functionapp,linux' ? true : false
    publicNetworkAccess: 'Enabled'
    virtualNetworkSubnetId: snetOutboundId //can cause error first time
    vnetRouteAllEnabled: true
    siteConfig: {
      alwaysOn: isFlexConsumptionTier ? false : true
      minTlsVersion: '1.2'
      http20Enabled: true
      appSettings: isFlexConsumptionTier ? union(funcAppSettingsFlex, appSettings) : union(funcAppSettings, appSettings)
      linuxFxVersion: kind == 'functionapp,linux' && !isFlexConsumptionTier ? 'DOTNET-ISOLATED|8.0' : null
      netFrameworkVersion: isFlexConsumptionTier ? null : 'v8.0'
      use32BitWorkerProcess: kind == 'functionapp,linux' ? false : true
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
        supportCredentials: false
      }
    }
    functionAppConfig: isFlexConsumptionTier
      ? {
          deployment: {
            storage: {
              type: 'blobcontainer'
              value: 'https://${storageName}.blob.${environment().suffixes.storage}/${storageContainerName}'
              authentication: {
                type: 'SystemAssignedIdentity'
              }
            }
          }
          runtime: {
            name: 'dotnet-isolated'
            version: '8.0'
          }
          scaleAndConcurrency: {
            maximumInstanceCount: 100
            instanceMemoryMB: 2048
          }
        }
      : null
  }
}

resource appSettingsWeb 'Microsoft.Web/sites/config@2024-04-01' = if (!isFlexConsumptionTier) {
  name: 'web'
  parent: func
  properties: {
    healthCheckPath: '/health/index.html'
  }
}

resource authR 'Microsoft.Web/sites/config@2024-04-01' = {
  name: 'authsettingsV2'
  parent: func
  properties: {
    platform: {
      enabled: !empty(auth)
      runtimeVersion: '~1'
    }
    httpSettings: {
      requireHttps: true
      forwardProxy: {
        convention: 'NoProxy'
      }
      routes: {
        apiPrefix: '/.auth'
      }
    }
    globalValidation: {
      requireAuthentication: true
      unauthenticatedClientAction: 'Return401'
      excludedPaths: [
        '/api/health'
      ]
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: !empty(auth)
        registration: !empty(auth)
          ? {
              clientId: auth.authClientId
              openIdIssuer: 'https://sts.windows.net/${tenant().tenantId}/v2.0'
            }
          : null
        validation: {
          allowedAudiences: !empty(auth)
            ? [
                auth.?authAllowedAudience ?? 'abc'
              ]
            : []
          defaultAuthorizationPolicy: {
            allowedApplications: !empty(auth)
              ? [
                  auth.?authClientId ?? 'abc'
                ]
              : []
          }
        }
      }
    }
  }
}

resource funcSlot 'Microsoft.Web/sites/slots@2024-04-01' = if (!empty(slot) && !isFlexConsumptionTier) {
  name: slot.?name ?? 'stage'
  parent: func
  location: resourceGroup().location
  tags: { Slot: 'true' }
  identity: {
    type: 'SystemAssigned'
  }
  kind: kind
  properties: {
    serverFarmId: funcAppServicePlanId
    httpsOnly: true
    reserved: kind == 'functionapp,linux' ? true : false
    publicNetworkAccess: 'Disabled'
    virtualNetworkSubnetId: snetOutboundId
    vnetRouteAllEnabled: true
    siteConfig: {
      alwaysOn: true
      minTlsVersion: '1.2'
      http20Enabled: true
      appSettings: union(funcAppSettings, slot.?appSettings ?? [])
      linuxFxVersion: kind == 'functionapp,linux' ? 'DOTNET-ISOLATED|8.0' : null
      netFrameworkVersion: 'v8.0'
      use32BitWorkerProcess: kind == 'functionapp,linux' ? false : true
    }
  }
}

resource authSlotR 'Microsoft.Web/sites/slots/config@2024-04-01' = if (!empty(slot) && !isFlexConsumptionTier) {
  name: 'authsettingsV2'
  parent: funcSlot
  properties: {
    platform: {
      enabled: !empty(slot) && bool(slot.?authEnabled ?? false)
      runtimeVersion: '~1'
    }
    httpSettings: {
      requireHttps: true
      forwardProxy: {
        convention: 'NoProxy'
      }
      routes: {
        apiPrefix: '/.auth'
      }
    }
    globalValidation: {
      requireAuthentication: true
      unauthenticatedClientAction: 'Return401'
      excludedPaths: [
        '/api/health'
      ]
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: !empty(slot) && bool(slot.?authEnabled ?? false)
        registration: !empty(slot) && bool(slot.?authEnabled ?? false)
          ? {
              clientId: auth.authClientId
              openIdIssuer: 'https://sts.windows.net/${tenant().tenantId}/v2.0'
            }
          : null
        validation: {
          allowedAudiences: !empty(slot) && bool(slot.?authEnabled ?? false)
            ? [
                auth.?authAllowedAudience ?? 'abc'
              ]
            : []
          defaultAuthorizationPolicy: {
            allowedApplications: !empty(slot) && bool(slot.?authEnabled ?? false)
              ? [
                  auth.?authClientId ?? 'abc'
                ]
              : []
          }
        }
      }
    }
  }
}

resource hostNamedBindings 'Microsoft.Web/sites/hostNameBindings@2024-04-01' = if (!empty(customDomain)) {
  name: empty(customDomain) ? 'x.com' : '${customDomain}.domainabc.se'
  parent: func
  properties: {
    hostNameType: 'Verified'
    siteName: name
    sslState: 'SniEnabled'
    thumbprint: thumbprint
  }
}

resource hostNamedBindingsSlots 'Microsoft.Web/sites/slots/hostNameBindings@2024-04-01' = if (!empty(slot) && !empty(slot.?customDomain) && !isFlexConsumptionTier) {
  name: empty(slot.?customDomain) ? 'x.com' : '${slot.?customDomain}-stage.domainabc.se'
  parent: funcSlot
  properties: {
    hostNameType: 'Verified'
    siteName: funcSlot.name
    sslState: 'SniEnabled'
    thumbprint: thumbprint
  }
}

resource pepR 'Microsoft.Network/privateEndpoints@2024-05-01' = [
  for pep in items(privateEndpoints): if (!empty(slot) && pep.key == 'sites' || pep.key == 'sites-stage' && !isFlexConsumptionTier) {
    name: 'pep-${name}-${pep.key}'
    location: resourceGroup().location
    //tags: resourceGroup().tags
    dependsOn: pep.key == 'sites-stage'
      ? [
          funcSlot
        ]
      : []
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
          name: '${func.name}-${pep.key}'
          properties: {
            privateLinkServiceId: func.id
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
  for (pep, i) in items(privateEndpoints): if (!empty(slot) && pep.key == 'sites' || pep.key == 'sites-stage' && !isFlexConsumptionTier) {
    name: 'default'
    parent: pepR[i]
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'azurewebsites-${pep.key}-${i}'
          properties: {
            privateDnsZoneId: privateDnsZoneId
          }
        }
      ]
    }
  }
]

resource rbacStorage 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, func.id, 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  properties: {
    principalId: func.identity.principalId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleAssignments',
      'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    )
    principalType: 'ServicePrincipal'
  }
}

resource rbacStorageSlot 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(slot) && !isFlexConsumptionTier) {
  name: guid(resourceGroup().id, funcSlot.id, 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  properties: {
    principalId: funcSlot.identity.principalId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleAssignments',
      'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    )
    principalType: 'ServicePrincipal'
  }
}

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
