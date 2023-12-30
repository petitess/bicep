param name string
param location string
param tags object = resourceGroup().tags
param appiId string = ''


resource func 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  kind: 'functionapp'
  location: location
  tags: !empty(appiId) ? union(tags, {
      'hidden-link: /app-insights-resource-id': appiId
    }) : tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
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
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: !empty(appiId) ? reference(appiId, '2020-02-02').ConnectionString : 'x'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${st.name};AccountKey=${listKeys(st.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${st.name};AccountKey=${listKeys(st.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: 'funcconsamptionaa56'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'WEBSITE_ENABLE_SYNC_UPDATE_SITE'
          value: 'true'
        }
      ]
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
      use32BitWorkerProcess: true
      ftpsState: 'FtpsOnly'
      powerShellVersion: '7.2'
      netFrameworkVersion: 'v6.0'
    }
    clientAffinityEnabled: false
    publicNetworkAccess: 'Enabled'
    httpsOnly: true
    serverFarmId: asp.id
  }
}

resource asp 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: 'asp-${name}'
  location: location
  kind: 'app'
  properties: {}
  sku: {
    name: 'Y1'
  }
}

resource st 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: replace('st${name}', '-', '')
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

output principalId string = func.identity.principalId
