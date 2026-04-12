param env string
param location string
param tags object = resourceGroup().tags

resource log 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
  name: 'log-apim-${env}-01'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource appi 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-apim-${env}-01'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Disabled'
    Request_Source: 'rest'
    RetentionInDays: 30
    IngestionMode: 'LogAnalytics'
    WorkspaceResourceId: log.id
  }
}

output appiName string = appi.name
output appiId string = appi.id
output instrumentationKey string = appi.properties.InstrumentationKey
output logName string = log.name
output logId string = log.id
