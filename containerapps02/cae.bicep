param caeName string
param stKey string
param location string = resourceGroup().location

resource cae 'Microsoft.App/managedEnvironments@2025-10-02-preview' = {
  name: caeName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: log.properties.customerId
        dynamicJsonColumns: false
        sharedKey: log.listKeys().primarySharedKey
      }
    }
    zoneRedundant: false
    kedaConfiguration: {}
    daprConfiguration: {}
    customDomainConfiguration: {}
    workloadProfiles: [
      {
        workloadProfileType: 'Consumption'
        name: 'Consumption'
        enableFips: false
      }
      {
        workloadProfileType: 'Consumption-GPU-NC8as-T4'
        name: 'GPU_WORKLOAD'
        enableFips: false
      }
    ]
    peerAuthentication: {
      mtls: {
        enabled: false
      }
    }
    peerTrafficConfiguration: {
      encryption: {
        enabled: false
      }
    }
    publicNetworkAccess: 'Enabled'
  }
}

resource caeStApi 'Microsoft.App/managedEnvironments/storages@2025-10-02-preview' = {
  parent: cae
  name: 'ollama-data'
  properties: {
    azureFile: {
      accountName: 'stollamadev01'
      shareName: 'ollamafileshare'
      accessMode: 'ReadWrite'
      accountKey: stKey
    }
  }
}

resource caeStUi 'Microsoft.App/managedEnvironments/storages@2025-10-02-preview' = {
  parent: cae
  name: 'openwebui-data'
  properties: {
    azureFile: {
      accountName: 'stollamadev01'
      shareName: 'openwebuifileshare'
      accessMode: 'ReadWrite'
      accountKey: stKey
    }
  }
}


resource log 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
  name: 'log-${caeName}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      legacy: 0
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: json('-1')
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output caeId string = cae.id
