targetScope = 'resourceGroup'

param env string
param location string
param appiconstring string
param KeyVaultUrl string
param keyvaultadmin string

var tags = resourceGroup().tags

resource plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'app-itglueint-${env}-plan-01'
  location: location
  tags: tags
  kind: 'app'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {}
}

resource app 'Microsoft.Web/sites@2022-03-01' = {
  name: 'app-itglue-${env}-01'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    siteConfig: {
      phpVersion: 'OFF'
      netFrameworkVersion: 'v7.0'
      ftpsState: 'FtpsOnly'
      alwaysOn: true
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      http20Enabled: true
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appiconstring
        }
        {
          name: 'KeyVaultUrl'
          value: KeyVaultUrl
        }
      ]
    }
    serverFarmId: plan.id
    clientAffinityEnabled: true
    httpsOnly: true
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
  }
}

resource config1 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'web'
  parent: app
  properties: {
    pythonVersion: 'OFF'
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
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
      {
        virtualPath: '/AzureInventering.Sub1'
        physicalPath: 'site\\wwwroot\\app_data\\jobs\\triggered\\AzureInventering.Sub1'
        preloadEnabled: true
      }
      {
        virtualPath: '/UpdateItGlue'
        physicalPath: 'site\\wwwroot\\app_data\\jobs\\triggered\\UpdateItGlue'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    localMySqlEnabled: false
    managedServiceIdentityId: 29953
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 1
  }
}

resource role 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(subscription().id, '1', keyvaultadmin)
  scope: resourceGroup()
  properties: {
    principalType: 'ServicePrincipal'
    principalId: app.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyvaultadmin)
  }
}

output serverfarmsid string = plan.id
output serverfarmsname string = plan.name
output appid string = app.id
output principalId string = app.identity.principalId
