targetScope = 'resourceGroup'

param name string
param location string

var tags = resourceGroup().tags

resource func 'Microsoft.Web/sites@2022-03-01' = {
  name: replace(name,'-','')
  location: location
  tags: tags
  kind: 'functionapp'
  identity: {
     type: 'SystemAssigned'
  }
  properties: {
     enabled: true
     httpsOnly: true
     serverFarmId: hostingPlan.id
     clientAffinityEnabled: false
     siteConfig: {
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
      use32BitWorkerProcess: true
      powerShellVersion: '7.2'
      netFrameworkVersion: 'v6.0'
      ftpsState:  'FtpsOnly'
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'powershell'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
      }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: uniqueString(resourceGroup().id)
        }
      ]
     }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: replace('${name}st','-','')
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: replace('${name}appi','-','')
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    WorkspaceResourceId: workspace.id
  }
  tags: union(tags,{
    // circular dependency means we can't reference functionApp directly  /subscriptions/<subscriptionId>/resourceGroups/<rg-name>/providers/Microsoft.Web/sites/<appName>"
     'hidden-link:/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/sites/${replace('${name}appi','-','')}': 'Resource'
  })
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: replace('${name}plan','-','')
  location: location
  tags: tags
  sku: {
    name: 'Y1' 
    tier: 'Dynamic'
  }
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: replace('${name}log','-','')
  location: location
}

module rbac 'rbac.bicep' = {
  scope: subscription()
  name: 'module-${name}-rbac01'
  params: {
    principalId: func.identity.principalId
  }
}
