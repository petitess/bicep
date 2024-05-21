param name string
param logId string

resource appi 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: resourceGroup().location
  tags: resourceGroup().tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaWebAppExtensionCreate'
    RetentionInDays: 30
    WorkspaceResourceId: logId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output connectionString string = appi.properties.ConnectionString
