metadata name = 'Web/Function Apps'
metadata description = 'This module deploys a Web or Function App.'

@description('Required. Name of the site.')
param name string

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Required. Type of site to deploy.')
@allowed([
  'functionapp' // function app windows os
  'functionapp,linux' // function app linux os
  'functionapp,workflowapp' // logic app workflow
  'functionapp,workflowapp,linux' // logic app docker container
  'functionapp,linux,container' // function app linux container
  'functionapp,linux,container,azurecontainerapps' // function app linux container azure container apps
  'app,linux' // linux web app
  'app' // windows web app
  'linux,api' // linux api app
  'api' // windows api app
  'app,linux,container' // linux container app
  'app,container,windows' // windows container app
])
param kind string

@description('Required. The resource ID of the app service plan to use for the site. Set as empty string when using a managed environment id for container apps.')
param serverFarmResourceId string

@description('Optional. Azure Resource Manager ID of the customers selected Managed Environment on which to host this app.')
param managedEnvironmentResourceId string?

@description('Optional. Configures a site to accept only HTTPS requests. Issues redirect for HTTP requests.')
param httpsOnly bool = true

@description('Optional. If client affinity is enabled.')
param clientAffinityEnabled bool = true

@description('Optional. To enable client affinity; false to stop sending session affinity cookies, which route client requests in the same session to the same instance. Default is true.')
param clientAffinityProxyEnabled bool = true

@description('Optional. To enable client affinity partitioning using CHIPS cookies, this will add the partitioned property to the affinity cookies; false to stop sending partitioned affinity cookies. Default is false.')
param clientAffinityPartitioningEnabled bool = false

@description('Optional. The resource ID of the app service environment to use for this resource.')
param appServiceEnvironmentResourceId string?

import { managedIdentityAllType } from 'br/public:avm/utl/types/avm-common-types:0.6.0'
@description('Optional. The managed identity definition for this resource.')
param managedIdentities managedIdentityAllType?

@description('Optional. The resource ID of the assigned identity to be used to access a key vault with.')
param keyVaultAccessIdentityResourceId string?

@description('Optional. Checks if Customer provided storage account is required.')
param storageAccountRequired bool = false

@description('Optional. Azure Resource Manager ID of the Virtual network and subnet to be joined by Regional VNET Integration. This must be of the form /subscriptions/{subscriptionName}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{vnetName}/subnets/{subnetName}.')
param virtualNetworkSubnetOutboundResourceId string?

@description('Optional. Stop SCM (KUDU) site when the app is stopped.')
param scmSiteAlsoStopped bool = false

@description('Optional. The site config object. The defaults are set to the following values: alwaysOn: true, minTlsVersion: \'1.2\', ftpsState: \'FtpsOnly\'.')
param siteConfig resourceInput<'Microsoft.Web/sites@2024-11-01'>.properties.siteConfig = {
  alwaysOn: true
  minTlsVersion: '1.2'
  ftpsState: 'FtpsOnly'
}

@description('Optional. The outbound VNET routing configuration for the site.')
param outboundVnetRouting resourceInput<'Microsoft.Web/sites@2024-11-01'>.properties.outboundVnetRouting?

@description('Optional. SCM Basic Auth Publishing Credentials.')
param enableBasicAuthScm bool = false
@description('Optional. FTP Basic Auth Publishing Credentials.')
param enableBasicAuthFtp bool = false

@description('Optional. The Function App configuration object.')
param functionAppConfig resourceInput<'Microsoft.Web/sites@2024-04-01'>.properties.functionAppConfig?

import { lockType } from 'br/public:avm/utl/types/avm-common-types:0.6.0'
@description('Optional. The lock settings of the service.')
param lock lockType?

@description('Optional. Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible. Specify the private IP address.')
param privateEndpoints ({ sites: string?, 'sites-stage': string? }) = {}

@description('Subnet for private endpoints.')
param virtualNetworkSubnetInboundResourceId string?

@description('The resource ID of the private dns zone for private endpoints.')
param privateDnsZoneId string?

@description('Optional. Tags of the resource.')
param tags resourceInput<'Microsoft.Web/sites@2024-11-01'>.tags?

@description('Optional. To enable client certificate authentication (TLS mutual authentication).')
param clientCertEnabled bool = false

@description('Optional. Client certificate authentication comma-separated exclusion paths.')
param clientCertExclusionPaths string?

@description('''
Optional. This composes with ClientCertEnabled setting.
- ClientCertEnabled=false means ClientCert is ignored.
- ClientCertEnabled=true and ClientCertMode=Required means ClientCert is required.
- ClientCertEnabled=true and ClientCertMode=Optional means ClientCert is optional or accepted.
''')
param clientCertMode 'Optional' | 'OptionalInteractiveUser' | 'Required' = 'Optional'

@description('Optional. If specified during app creation, the app is cloned from a source app.')
param cloningInfo resourceInput<'Microsoft.Web/sites@2024-04-01'>.properties.cloningInfo?

@description('Optional. Size of the function container.')
param containerSize int?

@description('Optional. Maximum allowed daily memory-time quota (applicable on dynamic apps only).')
param dailyMemoryTimeQuota int?

@description('Optional. Setting this value to false disables the app (takes the app offline).')
param enabled bool = true

@description('Optional. Hostname SSL states are used to manage the SSL bindings for app\'s hostnames.')
param hostNameSslStates resourceInput<'Microsoft.Web/sites@2024-04-01'>.properties.hostNameSslStates?

@description('Optional. Hyper-V sandbox.')
param hyperV bool = false

@description('Optional. Site redundancy mode.')
@allowed([
  'ActiveActive'
  'Failover'
  'GeoRedundant'
  'Manual'
  'None'
])
param redundancyMode string = 'None'

@description('Optional. The app settings.')
param configAppsettings {
  *: string?
  APPLICATIONINSIGHTS_CONNECTION_STRING: string?
}?

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess ('Enabled' | 'Disabled')?

@description('Optional. End to End Encryption Setting.')
param e2eEncryptionEnabled bool?

@description('Optional. Property to configure various DNS related settings for a site.')
param dnsConfiguration resourceInput<'Microsoft.Web/sites@2024-04-01'>.properties.dnsConfiguration?

@description('Optional. Specifies the scope of uniqueness for the default hostname during resource creation.')
@allowed([
  'NoReuse'
  'ResourceGroupReuse'
  'SubscriptionReuse'
  'TenantReuse'
])
param autoGeneratedDomainNameLabelScope ('NoReuse' | 'ResourceGroupReuse' | 'SubscriptionReuse' | 'TenantReuse')?

@description('Custom domain for the app service. A thumbprint is required.')
param customDomain string?

@description('The thumbprint for the custom domain. A custom domain is required.')
param thumbprint string?

@description('Log analytics for diagnostic settings')
param workspaceId string?

param rbac ('Website Contributor' | 'Reader' | 'Contributor' | 'Storage Blob Data Contributor')[] = []

param hybridConnectionRelay resourceInput<'Microsoft.Web/sites/hybridConnectionNamespaces/relays@2024-11-01'>.properties?

@description('Optional. The authentication settings V2.')
param configAuthsettingsV2 configAuthsettingsV2_type?

@description('Optional. The web site config.')
param configWeb config_web_type

@description('Diagnostic settings for the app service. Specify workspace ID to enable.')
param diagnosticSettings diagnosticSettingsType = {}
// List of site kinds that support managed environment

@description('The type of a slot.')
param SLOT {
  @description('Required. Name of the slot.')
  name: string

  @description('Optional. Location for all Resources.')
  location: string?

  @description('Optional. The resource ID of the app service plan to use for the slot.')
  serverFarmResourceId: string?

  @description('Optional. Configures a slot to accept only HTTPS requests. Issues redirect for HTTP requests.')
  httpsOnly: bool?

  @description('Optional. If client affinity is enabled.')
  clientAffinityEnabled: bool?

  @description('Optional. The site config object.')
  siteConfig: resourceInput<'Microsoft.Web/sites/slots@2024-11-01'>.properties.siteConfig?

  @description('Optional. The Function App config object.')
  functionAppConfig: resourceInput<'Microsoft.Web/sites/slots@2024-11-01'>.properties.functionAppConfig?

  @description('Optional. Tags of the resource.')
  tags: object?

  @description('Optional. To enable client certificate authentication (TLS mutual authentication).')
  clientCertEnabled: bool?

  @description('Optional. Client certificate authentication comma-separated exclusion paths.')
  clientCertExclusionPaths: string?

  @description('Optional. This composes with ClientCertEnabled setting.</p>- ClientCertEnabled: false means ClientCert is ignored.</p>- ClientCertEnabled: true and ClientCertMode: Required means ClientCert is required.</p>- ClientCertEnabled: true and ClientCertMode: Optional means ClientCert is optional or accepted.')
  clientCertMode: resourceInput<'Microsoft.Web/sites/slots@2024-04-01'>.properties.clientCertMode?

  @description('Optional. If specified during app creation, the app is cloned from a source app.')
  cloningInfo: resourceInput<'Microsoft.Web/sites/slots@2024-04-01'>.properties.cloningInfo?

  @description('Optional. Size of the function container.')
  containerSize: int?

  @description('Optional. Maximum allowed daily memory-time quota (applicable on dynamic apps only).')
  dailyMemoryTimeQuota: int?

  @description('Optional. Setting this value to false disables the app (takes the app offline).')
  enabled: bool?

  @description('Optional. Hostname SSL states are used to manage the SSL bindings for app\'s hostnames.')
  hostNameSslStates: resourceInput<'Microsoft.Web/sites/slots@2024-04-01'>.properties.hostNameSslStates?

  @description('Optional. Hyper-V sandbox.')
  hyperV: bool?

  @description('Optional. Allow or block all public traffic.')
  publicNetworkAccess: ('Enabled' | 'Disabled')?

  @description('Optional. Site redundancy mode.')
  redundancyMode: resourceInput<'Microsoft.Web/sites/slots@2024-04-01'>.properties.redundancyMode?

  @description('Optional. Property to configure various DNS related settings for a site.')
  dnsConfiguration: resourceInput<'Microsoft.Web/sites/slots@2024-04-01'>.properties.dnsConfiguration?

  @description('Optional. Specifies the scope of uniqueness for the default hostname during resource creation.')
  autoGeneratedDomainNameLabelScope: ('NoReuse' | 'ResourceGroupReuse' | 'SubscriptionReuse' | 'TenantReuse')?
  @description('Optional. The app settings.')
  configAppsettings: {
    *: string?
    APPLICATIONINSIGHTS_CONNECTION_STRING: string?
  }?
  @description('Optional. The web site config.')
  configWeb: config_web_type
  @description('Optional. SCM Basic Auth Publishing Credentials.')
  enableBasicAuthScm: bool?
  @description('Optional. FTP Basic Auth Publishing Credentials.')
  enableBasicAuthFtp: bool?
  @description('Optional. The authentication settings V2.')
  configAuthsettingsV2: configAuthsettingsV2_type?
  @description('Optional. Checks if Customer provided storage account is required.')
  storageAccountRequired: bool?
  @description('Diagnostic settings for the app service slot. Specify workspace ID to enable.')
  diagnosticSettings: diagnosticSettingsType?
  @description('Custom domain for the app service. A thumbprint is required.')
  customDomain: string?
  @description('The thumbprint for the custom domain. A custom domain is required.')
  thumbprint: string?
}?
var managedEnvironmentSupportedKinds = [
  'functionapp,linux,container,azurecontainerapps'
]

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var identity = !empty(managedIdentities)
  ? {
      type: (managedIdentities.?systemAssigned ?? false)
        ? (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'SystemAssigned, UserAssigned' : 'SystemAssigned')
        : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : 'None')
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

var rolesList = {
  'Website Contributor': 'Website Contributor'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  'Storage Blob Data Contributor': 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

type diagnosticSettingsType = ({
  'AppServiceAntivirusScanAuditLogs': bool?
  'AppServiceHTTPLogs': bool?
  'AppServiceConsoleLogs': bool?
  'AppServiceAppLogs': bool?
  'AppServiceFileAuditLogs': bool?
  'AppServiceAuditLogs': bool?
  'AppServiceIPSecAuditLogs': bool?
  'AppServicePlatformLogs': bool?
  'AppServiceAuthenticationLogs': bool?
})

type config_web_type = {
  acrUseManagedIdentityCreds: bool?
  acrUserManagedIdentityID: string?
  alwaysOn: bool?
  apiDefinition: {
    url: string
  }?
  apiManagementConfig: {
    id: string
  }?
  appCommandLine: string?
  appSettings: [
    {
      name: string
      value: string
    }
  ]?
  autoHealEnabled: bool?
  autoHealRules: {
    actions: {
      actionType: ('CustomAction' | 'LogEvent' | 'Recycle' | null)
      customAction: {
        exe: string
        parameters: string
      }
      minProcessExecutionTime: string
    }
    triggers: {
      privateBytesInKB: int
      requests: {
        count: int
        timeInterval: string
      }
      slowRequests: {
        count: int
        path: string
        timeInterval: string
        timeTaken: string
      }
      slowRequestsWithPath: [
        {
          count: int
          path: string
          timeInterval: string
          timeTaken: string
        }
      ]
      statusCodes: [
        {
          count: int
          path: string
          status: int
          subStatus: int
          timeInterval: string
          win32Status: int
        }
      ]
      statusCodesRange: [
        {
          count: int
          path: string
          statusCodes: string
          timeInterval: string
        }
      ]
    }
  }?
  autoSwapSlotName: string?
  azureStorageAccounts: {}?
  connectionStrings: [
    {
      connectionString: string
      name: string
      type: (
        | 'ApiHub'
        | 'Custom'
        | 'DocDb'
        | 'EventHub'
        | 'MySql'
        | 'NotificationHub'
        | 'PostgreSQL'
        | 'RedisCache'
        | 'SQLAzure'
        | 'SQLServer'
        | 'ServiceBus'
        | null)
    }
  ]?
  cors: {
    allowedOrigins: array
    supportCredentials: bool
  }?
  defaultDocuments: array?
  detailedErrorLoggingEnabled: bool?
  documentRoot: string?
  elasticWebAppScaleLimit: int?
  experiments: {
    rampUpRules: [
      {
        actionHostName: string
        changeDecisionCallbackUrl: string
        changeIntervalInMinutes: int
        changeStep: int
        maxReroutePercentage: int
        minReroutePercentage: int
        name: string
        reroutePercentage: int
      }
    ]
  }?
  ftpsState: string?
  functionAppScaleLimit: int?
  functionsRuntimeScaleMonitoringEnabled: bool?
  handlerMappings: [
    {
      arguments: string
      extension: string
      scriptProcessor: string
    }
  ]?
  healthCheckPath: string?
  http20Enabled: bool?
  httpLoggingEnabled: bool?
  ipSecurityRestrictions: [
    {
      action: string
      description: string
      headers: object
      ipAddress: string
      name: string
      priority: int
      subnetMask: string
      subnetTrafficTag: int
      tag: string
      vnetSubnetResourceId: string
      vnetTrafficTag: int
    }
  ]?
  ipSecurityRestrictionsDefaultAction: string?
  javaContainer: string?
  javaContainerVersion: string?
  javaVersion: string?
  keyVaultReferenceIdentity: string?
  limits: {
    maxDiskSizeInMb: int
    maxMemoryInMb: int
    maxPercentageCpu: int
  }?
  linuxFxVersion: string?
  loadBalancing: (
    | 'LeastRequests'
    | 'LeastRequestsWithTieBreaker'
    | 'LeastResponseTime'
    | 'PerSiteRoundRobin'
    | 'RequestHash'
    | 'WeightedRoundRobin'
    | 'WeightedTotalTraffic'
    | null)?
  localMySqlEnabled: bool?
  logsDirectorySizeLimit: int?
  managedPipelineMode: ('Classic' | 'Integrated' | null)?
  managedServiceIdentityId: int?
  metadata: [
    {
      name: string
      value: string
    }
  ]?
  minimumElasticInstanceCount: int?
  minTlsVersion: string?
  netFrameworkVersion: ('v8.0' | 'v9.0' | 'v10.0')?
  nodeVersion: string?
  numberOfWorkers: int?
  phpVersion: string?
  powerShellVersion: string?
  preWarmedInstanceCount: int?
  publicNetworkAccess: ('Enabled' | 'Disabled')?
  publishingUsername: string?
  push: {
    kind: string?
    properties: {
      dynamicTagsJson: string?
      isPushEnabled: bool?
      tagsRequiringAuth: string?
      tagWhitelistJson: string?
    }
  }?
  pythonVersion: string?
  remoteDebuggingEnabled: bool?
  remoteDebuggingVersion: ('VS2022')?
  requestTracingEnabled: bool?
  requestTracingExpirationTime: string?
  scmIpSecurityRestrictions: [
    {
      action: string
      description: string
      headers: object
      ipAddress: string
      name: string
      priority: int
      subnetMask: string
      subnetTrafficTag: int
      tag: string
      vnetSubnetResourceId: string
      vnetTrafficTag: int
    }
  ]?
  scmIpSecurityRestrictionsDefaultAction: string?
  scmIpSecurityRestrictionsUseMain: bool?
  scmMinTlsVersion: string?
  scmType: string?
  tracingOptions: string?
  use32BitWorkerProcess: bool?
  virtualApplications: [
    {
      physicalPath: string
      preloadEnabled: bool
      virtualDirectories: [
        {
          physicalPath: string
          virtualPath: string
        }
      ]
      virtualPath: string
    }
  ]?
  vnetName: string?
  vnetPrivatePortsCount: int?
  vnetRouteAllEnabled: bool?
  websiteTimeZone: string?
  webSocketsEnabled: bool?
  windowsFxVersion: string?
  xManagedServiceIdentityId: int?
}?

type configAuthsettingsV2_type = {
  globalValidation: {
    excludedPaths: array
    redirectToProvider: string
    requireAuthentication: bool
    unauthenticatedClientAction: ('AllowAnonymous' | 'RedirectToLoginPage' | 'Return401' | 'Return403')
  }?
  httpSettings: {
    forwardProxy: {
      convention: ('Custom' | 'NoProxy' | 'Standard')
      customHostHeaderName: string
      customProtoHeaderName: string
    }
    requireHttps: bool
    routes: {
      apiPrefix: string
    }
  }?
  identityProviders: {
    azureActiveDirectory: {
      enabled: bool
      isAutoProvisioned: bool
      login: {
        disableWWWAuthenticate: bool
        loginParameters: array
      }
      registration: {
        clientId: string
        clientSecretCertificateIssuer: string
        clientSecretCertificateSubjectAlternativeName: string
        clientSecretCertificateThumbprint: string
        clientSecretSettingName: string
        openIdIssuer: string
      }
      validation: {
        allowedAudiences: array
        defaultAuthorizationPolicy: {
          allowedApplications: array
          allowedPrincipals: {
            groups: array
            identities: array
          }
        }
      }
    }
  }?
  login: {
    allowedExternalRedirectUrls: array
    cookieExpiration: {
      convention: ('FixedTime' | 'IdentityProviderDerived')
      timeToExpiration: string
    }
    nonce: {
      nonceExpirationInterval: string
      validateNonce: bool
    }
    preserveUrlFragmentsForLogins: bool
    routes: {
      logoutEndpoint: string
    }
    tokenStore: {
      azureBlobStorage: {
        sasUrlSettingName: string
      }
      enabled: bool
      fileSystem: {
        directory: string
      }
      tokenRefreshExtensionHours: int
    }
  }?
  platform: {
    configFilePath: string?
    enabled: bool
    runtimeVersion: ('~1')?
  }?
}?

resource app 'Microsoft.Web/sites@2024-11-01' = {
  name: name
  location: location
  kind: kind
  tags: tags
  identity: identity
  properties: {
    managedEnvironmentId: !empty(managedEnvironmentResourceId) ? managedEnvironmentResourceId : null
    serverFarmId: contains(managedEnvironmentSupportedKinds, kind) && !empty(managedEnvironmentResourceId)
      ? null
      : serverFarmResourceId
    clientAffinityEnabled: clientAffinityEnabled
    clientAffinityProxyEnabled: clientAffinityProxyEnabled
    clientAffinityPartitioningEnabled: clientAffinityPartitioningEnabled
    httpsOnly: httpsOnly
    hostingEnvironmentProfile: !empty(appServiceEnvironmentResourceId)
      ? {
          id: appServiceEnvironmentResourceId
        }
      : null
    storageAccountRequired: storageAccountRequired
    keyVaultReferenceIdentity: keyVaultAccessIdentityResourceId
    virtualNetworkSubnetId: virtualNetworkSubnetOutboundResourceId
    siteConfig: siteConfig
    functionAppConfig: functionAppConfig
    clientCertEnabled: clientCertEnabled
    clientCertExclusionPaths: clientCertExclusionPaths
    clientCertMode: clientCertMode
    cloningInfo: cloningInfo
    containerSize: containerSize
    dailyMemoryTimeQuota: dailyMemoryTimeQuota
    enabled: enabled
    hostNameSslStates: hostNameSslStates
    hyperV: hyperV
    redundancyMode: redundancyMode
    publicNetworkAccess: !empty(publicNetworkAccess)
      ? any(publicNetworkAccess)
      : (!empty(privateEndpoints) ? 'Disabled' : 'Enabled')
    scmSiteAlsoStopped: scmSiteAlsoStopped
    endToEndEncryptionEnabled: e2eEncryptionEnabled
    dnsConfiguration: dnsConfiguration
    autoGeneratedDomainNameLabelScope: autoGeneratedDomainNameLabelScope
    outboundVnetRouting: outboundVnetRouting
  }
}

resource hostNamedBindings 'Microsoft.Web/sites/hostNameBindings@2024-04-01' = if (!empty(customDomain) && !empty(customDomain)) {
  name: empty(customDomain) ? 'x.com' : customDomain
  parent: app
  properties: {
    hostNameType: 'Verified'
    siteName: name
    sslState: 'SniEnabled'
    thumbprint: thumbprint
  }
}

resource hybridConnectionRelayy 'Microsoft.Web/sites/hybridConnectionNamespaces/relays@2024-11-01' = if (hybridConnectionRelay != null) {
  name: '${app.name}/${hybridConnectionRelay.relayName}/relay01'
  properties: hybridConnectionRelay
}

resource cred_pol_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-11-01' = {
  parent: app
  name: 'ftp'
  properties: {
    allow: enableBasicAuthFtp
  }
}

resource cred_pol_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-11-01' = {
  parent: app
  name: 'scm'
  properties: {
    allow: enableBasicAuthScm
  }
}

resource config_appset 'Microsoft.Web/sites/config@2024-11-01' = if (configAppsettings != null) {
  parent: app
  name: 'appsettings'
  properties: configAppsettings
}

resource config_appset_slot_conf_names 'Microsoft.Web/sites/config@2024-11-01' = if (configAppsettings != null) {
  parent: app
  name: 'slotConfigNames'
  properties: {
    appSettingNames: [
      'SLOT_NAME'
    ]
  }
}

resource config_auth 'Microsoft.Web/sites/config@2024-11-01' = {
  parent: app
  name: 'authsettingsV2'
  properties: empty(configAuthsettingsV2)
    ? {
        platform: {
          enabled: false
        }
      }
    : configAuthsettingsV2
}

resource config_webb 'Microsoft.Web/sites/config@2024-11-01' = if (configWeb != null) {
  parent: app
  name: 'web'
  properties: configWeb
}

resource app_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.')
  }
  scope: app
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(workspaceId) && diagnosticSettings != null) {
  name: 'diag-${name}'
  scope: app
  properties: {
    workspaceId: workspaceId
    logs: [
      for c in items(diagnosticSettings): {
        category: c.key
        enabled: c.value
      }
    ]
  }
}

resource rbacR 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (r, i) in rbac: if (rbac != [] && identity != null) {
    name: guid(resourceGroup().id, app.id, r, string(i))
    properties: {
      principalId: app.identity.principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleAssignments', rolesList[r])
      principalType: 'ServicePrincipal'
    }
  }
]

resource app_SLOT 'Microsoft.Web/sites/slots@2024-11-01' = if (!empty(SLOT)) {
  name: SLOT.name
  parent: app
  location: location
  kind: kind
  tags: SLOT.?tags
  identity: identity
  properties: {
    managedEnvironmentId: !empty(managedEnvironmentResourceId) ? managedEnvironmentResourceId : null
    serverFarmId: contains(managedEnvironmentSupportedKinds, kind) && (!empty(app.properties.managedEnvironmentId) || !empty(managedEnvironmentResourceId))
      ? null
      : serverFarmResourceId
    clientAffinityEnabled: SLOT.?clientAffinityEnabled
    clientAffinityProxyEnabled: clientAffinityProxyEnabled
    clientAffinityPartitioningEnabled: clientAffinityPartitioningEnabled
    httpsOnly: SLOT.?httpsOnly
    hostingEnvironmentProfile: !empty(appServiceEnvironmentResourceId)
      ? {
          id: appServiceEnvironmentResourceId
        }
      : null
    storageAccountRequired: SLOT.?storageAccountRequired
    keyVaultReferenceIdentity: keyVaultAccessIdentityResourceId
    virtualNetworkSubnetId: virtualNetworkSubnetOutboundResourceId
    siteConfig: SLOT.?siteConfig
    functionAppConfig: SLOT.?functionAppConfig
    clientCertEnabled: SLOT.?clientCertEnabled
    clientCertExclusionPaths: SLOT.?clientCertExclusionPaths
    clientCertMode: SLOT.?clientCertMode
    cloningInfo: SLOT.?cloningInfo
    containerSize: SLOT.?containerSize
    dailyMemoryTimeQuota: SLOT.?dailyMemoryTimeQuota
    enabled: SLOT.?enabled
    hostNameSslStates: SLOT.?hostNameSslStates
    hyperV: SLOT.?hyperV
    publicNetworkAccess: SLOT.?publicNetworkAccess
    redundancyMode: SLOT.?redundancyMode
    dnsConfiguration: SLOT.?dnsConfiguration
    autoGeneratedDomainNameLabelScope: SLOT.?autoGeneratedDomainNameLabelScope
    outboundVnetRouting: outboundVnetRouting
  }
}

resource hostNamedBindingsSlots 'Microsoft.Web/sites/slots/hostNameBindings@2024-04-01' = if (!empty(SLOT) && !empty(SLOT.?customDomain)) {
  name: SLOT.?customDomain ?? 'x.com'
  parent: app_SLOT
  properties: {
    hostNameType: 'Verified'
    siteName: SLOT.name
    sslState: 'SniEnabled'
    thumbprint: thumbprint
  }
}

resource cred_pol_ftp_SLOT 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2024-11-01' = if (SLOT.?enableBasicAuthFtp != null) {
  parent: app_SLOT
  name: 'ftp'
  properties: {
    allow: bool(SLOT.?enableBasicAuthFtp)
  }
}

resource cred_pol_scm_SLOT 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2024-11-01' = if (SLOT.?enableBasicAuthScm != null) {
  parent: app_SLOT
  name: 'scm'
  properties: {
    allow: bool(SLOT.?enableBasicAuthScm)
  }
}

resource config_appset_SLOT 'Microsoft.Web/sites/slots/config@2024-11-01' = if (SLOT.?configAppsettings != null) {
  parent: app_SLOT
  name: 'appsettings'
  properties: SLOT.?configAppsettings
}

resource config_webb_SLOT 'Microsoft.Web/sites/slots/config@2024-11-01' = if (SLOT.?configWeb != null) {
  parent: app_SLOT
  name: 'web'
  properties: SLOT.?configWeb
}

resource config_auth_SLOT 'Microsoft.Web/sites/slots/config@2024-11-01' = if (SLOT != null) {
  parent: app_SLOT
  name: 'authsettingsV2'
  properties: empty(SLOT.?configAuthsettingsV2)
    ? {
        platform: {
          enabled: false
        }
      }
    : SLOT.?configAuthsettingsV2
}

resource rbacR_SLOT 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (r, i) in rbac: if (rbac != [] && SLOT != null && identity != null) {
    name: guid(resourceGroup().id, app_SLOT.id, r, string(i))
    properties: {
      principalId: app_SLOT.identity.principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleAssignments', rolesList[r])
      principalType: 'ServicePrincipal'
    }
  }
]

resource diag_SLOT 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(workspaceId) && SLOT.?diagnosticSettings != null) {
  name: 'diag-${app_SLOT.name}'
  scope: app_SLOT
  properties: {
    workspaceId: workspaceId
    logs: [
      for c in items(SLOT.?diagnosticSettings ?? {}): {
        category: c.key
        enabled: c.value
      }
    ]
  }
}

resource pepR 'Microsoft.Network/privateEndpoints@2024-07-01' = [
  for pep in items(privateEndpoints): if (pep.key == 'sites' || !empty(SLOT) && pep.key == 'sites-stage') {
    name: 'pep-${name}-${pep.key}'
    location: location
    dependsOn: pep.key == 'sites-stage'
      ? [
          app_SLOT
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
          name: 'plsc-${pep.key}'
          properties: {
            privateLinkServiceId: app.id
            groupIds: [
              pep.key
            ]
          }
        }
      ]
      subnet: {
        id: virtualNetworkSubnetInboundResourceId
      }
    }
  }
]

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = [
  for (pep, i) in items(privateEndpoints): if (pep.key == 'sites' || !empty(SLOT) && pep.key == 'sites-stage') {
    name: 'default'
    parent: pepR[i]
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'azurewebsites'
          properties: {
            privateDnsZoneId: privateDnsZoneId
          }
        }
      ]
    }
  }
]

@description('The name of the site.')
output name string = app.name

@description('The resource ID of the site.')
output resourceId string = app.id

@description('The resource group the site was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string? = app.?identity.?principalId

@description('The location the resource was deployed into.')
output location string = app.location

@description('Default hostname of the app.')
output defaultHostname string = app.properties.defaultHostName

@description('Unique identifier that verifies the custom domains assigned to the app. Customer will add this ID to a txt record for verification.')
output customDomainVerificationId string = app.properties.customDomainVerificationId

@description('The outbound IP addresses of the app.')
output outboundIpAddresses string = app.properties.outboundIpAddresses

