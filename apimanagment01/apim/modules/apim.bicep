param initialDeploy bool = true
param name string
param location string
param tags object = resourceGroup().tags
param skuName
  | 'Basic'
  | 'Consumption'
  | 'Developer'
  | 'Isolated'
  | 'Premium'
  | 'Standard'
  | 'BasicV2'
  | 'StandardV2'
  | 'PremiumV2' = 'Developer'
param skuCapacity int = 1
param publisherName string
param publisherEmail string
@allowed([
  'None'
  'Internal'
  'External'
])
param virtualNetworkType string = 'None'
param vnetName string
param vnetResourceGroup string
param snetName string
param customProperties object = {}
param hostnameApi string
param hostnamePortal string
param hostnameManagement string
param keyVaultId string
param workspaceId string
param appiName string
param appiId string
param instrumentationKey string
param prefixCert string
param prefixSpoke string
param sslCertificates array
param afdId string

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

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)

  resource snet 'subnets' existing = {
    name: snetName
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
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

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: 'kv-${prefixCert}-01'
  scope: resourceGroup('rg-${prefixSpoke}-01')

  resource secret 'secrets' existing = [
    for sslCertificate in sslCertificates: {
      name: sslCertificate
    }
  ]
}

resource apim 'Microsoft.ApiManagement/service@2024-06-01-preview' = {
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
    publicIpAddressId: pip.id
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
      : [
          {
            type: 'Proxy'
            hostName: hostnameApi
            keyVaultId: keyVaultId
          }
          {
            type: 'DeveloperPortal'
            hostName: hostnamePortal
            keyVaultId: keyVaultId
          }
          {
            type: 'Management'
            hostName: hostnameManagement
            keyVaultId: keyVaultId
          }
        ]
  }
}

resource removeHeadersAPIM 'Microsoft.ApiManagement/service/policies@2024-06-01-preview' = {
  name: 'policy'
  parent: apim
  properties: {
    value: headerPolicy
    format: 'rawxml'
  }
}

resource email 'Microsoft.ApiManagement/service/notifications/recipientEmails@2024-06-01-preview' = [
  for notification in notifications: if (false) {
    name: '${apim.name}/${notification}/${publisherEmail}'
  }
]

resource appiKey 'Microsoft.ApiManagement/service/namedValues@2024-06-01-preview' = {
  name: 'appi-key'
  parent: apim
  properties: {
    displayName: 'apiKey'
    value: instrumentationKey
    secret: true
  }
}

resource appiLogger 'Microsoft.ApiManagement/service/loggers@2024-06-01-preview' = {
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

resource azureMonistorLogger 'Microsoft.ApiManagement/service/loggers@2024-06-01-preview' = {
  name: 'azuremonitor'
  parent: apim
  properties: {
    loggerType: 'azureMonitor'
    isBuffered: true
  }
}

resource log 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-pip'
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

resource diag 'Microsoft.ApiManagement/service/diagnostics@2024-06-01-preview' = {
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
//App Reg Redirect URI:
//https://apim-abc-infra-apim-dev-we-02.developer.azure-api.net/signin
resource entraId 'Microsoft.ApiManagement/service/identityProviders@2024-06-01-preview' = {
  parent: apim
  name: 'aad'
  properties: {
    clientId: 'ec2c1e9b-12f0-1265-a5cc-ad69cc809487'
    type: 'aad'
    authority: 'login.microsoftonline.com'
    signinTenant: tenant().tenantId
    allowedTenants: [
      tenant().tenantId
    ]
    clientLibrary: 'MSAL-2'
    clientSecret: 'tj7ll3~Q2PGCzm~Jrlask'
  }
}

resource cert 'Microsoft.ApiManagement/service/certificates@2024-06-01-preview' = [
  for (cert, i) in sslCertificates: {
    parent: apim
    name: cert
    properties: {
      keyVault: {
        secretIdentifier: kv::secret[i].properties.secretUri
      }
    }
  }
]

output identityId { SystemAssigned: string, UserAssigned: string? } = {
  SystemAssigned: apim.identity.principalId
}
