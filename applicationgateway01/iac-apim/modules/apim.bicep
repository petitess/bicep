param initialDeploy bool = true
param name string
param location string
param tags object = resourceGroup().tags
param skuName resourceInput<'Microsoft.ApiManagement/service@2025-03-01-preview'>.sku.name = 'Developer'
param skuCapacity int = 0
param publisherName string = ''
param publisherEmail string = ''
param virtualNetworkType resourceInput<'Microsoft.ApiManagement/service@2025-03-01-preview'>.properties.virtualNetworkType?
param vnetName string
param vnetResourceGroup string
param kvName string
param snetName string
param customProperties object = {}
param hostnameApi string = ''
param hostnamePortal string = ''
param hostnameManagement string = ''
param workspaceId string = ''
param appiName string
param appiId string
param instrumentationKey string
param env string
param sslCertificates array
param afdId string
param snetPep string
param dnsRg string
param ipAddress string = ''

var capacity = skuName == 'Consumption' ? 0 : skuCapacity
var notifications = [
  'RequestPublisherNotificationMessage'
  'PurchasePublisherNotificationMessage'
  'NewApplicationNotificationMessage'
  'BCC'
  'NewIssuePublisherNotificationMessage'
  'AccountClosedPublisher'
  'QuotaLimitApproachingPublisherNotificationMessage'
]

var headerPolicy = replace(loadTextContent('../policies/mainPolicy.xml'), '{afdId}', afdId)

resource vnet 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)

  resource snet 'subnets' existing = {
    name: snetName
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2025-05-01' = if (!endsWith(skuName, 'V2')) {
  name: 'pip-${name}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: name
    }
  }
}

resource kvE 'Microsoft.KeyVault/vaults@2025-05-01' existing = {
  name: kvName
  scope: resourceGroup(vnetResourceGroup)

  resource secret 'secrets' existing = [
    for sslCertificate in sslCertificates: {
      name: sslCertificate
    }
  ]
}

resource apim 'Microsoft.ApiManagement/service@2025-03-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    capacity: capacity
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: !endsWith(skuName, 'V2') || initialDeploy ? 'Enabled' : 'Disabled'
    developerPortalStatus: 'Enabled'
    publicIpAddressId: !endsWith(skuName, 'V2') ? pip.id : null
    apiVersionConstraint: {
      minApiVersion: '2022-08-01'
    }
    publisherName: publisherName
    publisherEmail: publisherEmail
    virtualNetworkType: virtualNetworkType
    virtualNetworkConfiguration: {
      subnetResourceId: vnet::snet.id
    }
    customProperties: customProperties
    hostnameConfigurations: initialDeploy
      ? []
      : endsWith(skuName, 'V2')
          ? [
              {
                type: 'Proxy'
                hostName: hostnameApi
                keyVaultId: kvE::secret[0].properties.secretUri
              }
              {
                type: 'DeveloperPortal'
                hostName: hostnamePortal
                keyVaultId: kvE::secret[0].properties.secretUri
              }
            ]
          : [
              {
                type: 'Proxy'
                hostName: hostnameApi
                keyVaultId: kvE::secret[0].properties.secretUri
              }
              {
                type: 'DeveloperPortal'
                hostName: hostnamePortal
                keyVaultId: kvE::secret[0].properties.secretUri
              }
              {
                type: 'Management'
                hostName: hostnameManagement
                keyVaultId: kvE::secret[0].properties.secretUri
              }
            ]
  }
}

resource removeHeadersAPIM 'Microsoft.ApiManagement/service/policies@2025-03-01-preview' = {
  name: 'policy'
  parent: apim
  properties: {
    value: headerPolicy
    format: 'rawxml'
  }
}

resource email 'Microsoft.ApiManagement/service/notifications/recipientEmails@2025-03-01-preview' = [
  for notification in notifications: if (false) {
    name: '${apim.name}/${notification}/${publisherEmail}'
  }
]

resource appiKey 'Microsoft.ApiManagement/service/namedValues@2025-03-01-preview' = {
  name: 'appi-key'
  parent: apim
  properties: {
    displayName: 'apiKey'
    value: instrumentationKey
    secret: true
  }
}
@onlyIfNotExists()
resource appiLogger 'Microsoft.ApiManagement/service/loggers@2025-03-01-preview' = {
  parent: apim
  name: appiName
  properties: {
    loggerType: 'applicationInsights'
    credentials: {
      instrumentationKey: appiKey.listValue().value
    }
    isBuffered: true
    resourceId: appiId
  }
}

#disable-next-line use-recent-api-versions
resource log 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (workspaceId != '') {
  name: 'diag-apim'
  scope: apim
  properties: {
    workspaceId: workspaceId
    logs: [
      for c in items({ GatewayLogs: true, WebSocketConnectionLogs: true }): {
        category: c.key
        enabled: c.value
      }
    ]
  }
}

resource diag 'Microsoft.ApiManagement/service/diagnostics@2025-03-01-preview' = {
  parent: apim
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    httpCorrelationProtocol: 'Legacy'
    verbosity: 'information'
    logClientIp: true
    loggerId: appiLogger.id
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    frontend: {
      request: {
        headers: []
        body: {
          bytes: 0
        }
      }
      response: {
        headers: []
        body: {
          bytes: 0
        }
      }
    }
    backend: {
      request: {
        headers: []
        body: {
          bytes: 0
        }
      }
      response: {
        headers: []
        body: {
          bytes: 0
        }
      }
    }
  }
}

resource cert 'Microsoft.ApiManagement/service/certificates@2025-03-01-preview' = [
  for (cert, i) in sslCertificates: {
    parent: apim
    name: cert
    properties: {
      keyVault: {
        secretIdentifier: kvE::secret[i].properties.secretUri
      }
    }
  }
]

resource pep 'Microsoft.Network/privateEndpoints@2025-05-01' = if (endsWith(skuName, 'V2')) {
  name: 'pep-${apim.name}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-${apim.name}'
    subnet: {
      id: snetPep
    }
    ipConfigurations: ipAddress != ''
      ? [
          {
            name: 'config'
            properties: {
              groupId: 'Gateway'
              memberName: 'Gateway'
              privateIPAddress: ipAddress
            }
          }
        ]
      : []
    privateLinkServiceConnections: [
      {
        name: 'plsc'
        properties: {
          privateLinkServiceId: apim.id
          groupIds: [
            'Gateway'
          ]
        }
      }
    ]
  }
}

resource pdnszg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-05-01' = if (endsWith(skuName, 'V2')) {
  name: 'default'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'azure-api'
        properties: {
          privateDnsZoneId: resourceId(dnsRg, 'Microsoft.Network/privateDnsZones', 'privatelink.azure-api.net')
        }
      }
    ]
  }
}
@onlyIfNotExists()
resource pdnszClassicTier 'Microsoft.Network/privateDnsZones@2024-06-01' = if (!endsWith(skuName, 'V2')) {
  name: '${name}.azure-api.net'
  location: 'global'
  tags: tags
  @onlyIfNotExists()
  resource a 'A' = {
    name: '@'
    properties: {
      ttl: 3600
      aRecords: [
        {
          ipv4Address: apim.properties.privateIPAddresses[0]
        }
      ]
    }
  }
  @onlyIfNotExists()
  resource apimLink 'virtualNetworkLinks' = {
    name: 'link-${name}'
    location: 'global'
    properties: {
      virtualNetwork: {
        id: vnet.id
      }
      registrationEnabled: false
    }
  }
}
@onlyIfNotExists()
resource pdnszCustom 'Microsoft.Network/privateDnsZones@2024-06-01' = if (hostnameApi != '' && ipAddress != '') {
  name: hostnameApi
  location: 'global'
  tags: tags
  @onlyIfNotExists()
  resource a 'A' = {
    name: '@'
    properties: {
      ttl: 3600
      aRecords: [
        {
          ipv4Address: endsWith(skuName, 'V2') ? ipAddress : apim.properties.privateIPAddresses[0]
        }
      ]
    }
  }
  @onlyIfNotExists()
  resource apimLink 'virtualNetworkLinks' = {
    name: 'link-${name}'
    location: 'global'
    properties: {
      virtualNetwork: {
        id: vnet.id
      }
      registrationEnabled: false
    }
  }
}

module rbacKv 'rbac.bicep' = {
  scope: resourceGroup('rg-vnet-sys-${env}-01')
  name: 'rbac-kv-apim'
  params: {
    principalId: apim.identity.principalId
    roles: ['Key Vault Administrator']
  }
}

module rbacKv2 'rbac.bicep' = {
  name: 'rbac-kv-apim-2'
  params: {
    principalId: apim.identity.principalId
    roles: ['Key Vault Administrator']
  }
}
