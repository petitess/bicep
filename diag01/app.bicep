param env string

param location string
param stId string

var tags = resourceGroup().tags
var unique = take(subscription().subscriptionId, 4)

resource asp 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'asp-${env}-01'
  location: location
  tags: tags
  sku: {
    name: env == 'prod' ? 'S1' : 'S1'
    tier: env == 'prod' ? 'Standard' : 'Standard'
    size: env == 'prod' ? 'S1' : 'S1'
    family: env == 'prod' ? 'S' : 'S'
    capacity: env == 'prod' ? 1 : 1
  }
  kind: 'app'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource app 'Microsoft.Web/sites@2022-09-01' = {
  name: 'app-itglue-${unique}-${env}-01'
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
      appSettings: []
    }
    serverFarmId: asp.id
    clientAffinityEnabled: true
    httpsOnly: true
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${app.name}'
  scope: app
  properties: {
    storageAccountId: stId
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
      }
      {
        category: 'AppServiceIPSecAuditLogs'
        enabled: true
      }
      {
        category: 'AppServicePlatformLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
