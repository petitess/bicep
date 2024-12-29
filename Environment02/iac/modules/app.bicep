targetScope = 'resourceGroup'

param location string
param name string
param aspId string
param snetOutboundId string
param snetPepId string
param privateEndpoints ({ sites: string?, 'sites-stage': string? })
param LogId string
param thumbprint string
param dnsRg string
param healthpath string = '/api/Health'
param actionGroupId string
param alertsEnabled bool = false
param virtualApplication array = []
param appSettings ({ name: string, value: string })[] = []
param customDomain string = ''
param keyVault ({ allowIPs: string[]?, ipPep: string?, customName: string? }) = {}
param auth ({ authClientId: string?, authAllowedAudience: string? })
param slot ({
  name: ('stage')?
  appSettings: ({ name: string, value: string })[]?
  customDomain: string?
  authEnabled: bool?
}) = {}

var kvName = 'kv-${name}'
var tags = resourceGroup().tags

var virtualApplications = concat(
  [
    {
      virtualPath: '/'
      physicalPath: 'site\\wwwroot'
      preloadEnabled: true
    }
  ],
  virtualApplication
)

resource app 'Microsoft.Web/sites@2024-04-01' = {
  name: name
  location: location
  tags: union(tags, {
    ApplicationTier: 'Frontend'
  })
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    siteConfig: {
      ftpsState: 'FtpsOnly'
      alwaysOn: true
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      http20Enabled: true
      appSettings: appSettings
      healthCheckPath: healthpath
    }
    serverFarmId: aspId
    clientAffinityEnabled: true
    httpsOnly: true
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    virtualNetworkSubnetId: snetOutboundId
    publicNetworkAccess: 'Disabled'
  }
}

resource Siteconfig 'Microsoft.Web/sites/config@2024-04-01' = {
  name: 'web'
  parent: app
  properties: {
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    virtualApplications: virtualApplications
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    functionsRuntimeScaleMonitoringEnabled: false
  }
}

resource HostBinding 'Microsoft.Web/sites/hostNameBindings@2024-04-01' = if (!empty(customDomain)) {
  name: empty(customDomain) ? 'none' : '${customDomain}.abcd.se'
  parent: app
  properties: {
    hostNameType: 'Verified'
    siteName: app.name
    sslState: 'SniEnabled'
    thumbprint: thumbprint
  }
}

resource authR 'Microsoft.Web/sites/config@2024-04-01' = {
  name: 'authsettingsV2'
  parent: app
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

resource diagapp 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${app.name}'
  scope: app
  properties: {
    workspaceId: LogId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
  }
}

resource appSlot 'Microsoft.Web/sites/slots@2024-04-01' = if (!empty(slot)) {
  name: slot.?name ?? 'stage'
  parent: app
  location: location
  tags: { Slot: 'true' }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: aspId
    httpsOnly: true
    publicNetworkAccess: 'Disabled'
    virtualNetworkSubnetId: snetOutboundId
    vnetRouteAllEnabled: true
    siteConfig: {
      alwaysOn: true
      minTlsVersion: '1.2'
      http20Enabled: true
      appSettings: union(appSettings, slot.?appSettings ?? [])
      netFrameworkVersion: 'v8.0'
    }
  }
}

resource hostNamedBindingsSlots 'Microsoft.Web/sites/slots/hostNameBindings@2024-04-01' = if (!empty(slot) && !empty(slot.?customDomain)) {
  name: empty(slot.?customDomain) ? 'none' : '${slot.?customDomain}-stage.abcd.se'
  parent: appSlot
  properties: {
    hostNameType: 'Verified'
    siteName: appSlot.name
    sslState: 'SniEnabled'
    thumbprint: thumbprint
  }
}


resource authSlotR 'Microsoft.Web/sites/slots/config@2024-04-01' = if (!empty(slot)) {
  name: 'authsettingsV2'
  parent: appSlot
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

resource pepApp 'Microsoft.Network/privateEndpoints@2024-05-01' = [
  for pep in items(privateEndpoints): if (!empty(slot) && pep.key == 'sites-stage' || pep.key == 'sites') {
    name: 'pep-${name}-${pep.key}'
    location: location
    dependsOn: pep.key == 'sites-stage'
      ? [
          appSlot
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
          name: '${app.name}-${pep.key}'
          properties: {
            privateLinkServiceId: app.id
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
  for (pep, i) in items(privateEndpoints): if (!empty(slot) && pep.key == 'sites-stage' || pep.key == 'sites') {
    name: 'default'
    parent: pepApp[i]
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'azurewebsites-${pep.key}-${i}'
          properties: {
            privateDnsZoneId: resourceId(dnsRg, 'Microsoft.Network/privateDnsZones', 'privatelink.azurewebsites.net')
          }
        }
      ]
    }
  }
]

resource unhealthyMetricAlertRule 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-${app.name}'
  location: 'Global'
  properties: {
    enabled: alertsEnabled
    severity: 2
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    scopes: [app.id]
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'Metric1'
          criterionType: 'StaticThresholdCriterion'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: 'HealthCheckStatus'
          timeAggregation: 'Minimum'
          operator: 'LessThan'
          threshold: 100
          skipMetricValidation: false
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
}

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = if (!empty(keyVault)) {
  name: (keyVault.?customName ?? null) != null ? keyVault.?customName : kvName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: false
    softDeleteRetentionInDays: 90
    publicNetworkAccess: 'disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules:  [
        for i in keyVault.?allowIPs ?? [] : {
          value: i
        }
      ]
    }
  }
}

resource diagkv 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(keyVault)) {
  name: 'diag-${kv.name}'
  scope: kv
  properties: {
    workspaceId: LogId
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
  }
}

resource pepKv 'Microsoft.Network/privateEndpoints@2024-05-01' = if (!empty(keyVault)) {
  name: 'pep-${kv.name}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-${kv.name}'
    ipConfigurations: [
      {
        name: 'config-${kv.name}'
        properties: {
          groupId: 'vault'
          memberName: 'default'
          privateIPAddress: keyVault.?ipPep
        }
      }
    ]
    subnet: {
      id: snetPepId
    }
    privateLinkServiceConnections: [
      {
        name: kv.name
        properties: {
          privateLinkServiceId: kv.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource pdnszkv 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = if (!empty(keyVault)) {
  name: 'Default'
  parent: pepKv
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-vaultcore-azure-net'
        properties: {
          privateDnsZoneId: resourceId(dnsRg, 'Microsoft.Network/privateDnsZones', 'privatelink.vaultcore.azure.net')
        }
      }
    ]
  }
}

// output id string = app.id
output appName string = app.name
output principalId string = app.identity.principalId
