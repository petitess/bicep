param name string
param location string
param tags object = resourceGroup().tags
param WorkspaceResourceId string

resource appi 'Microsoft.Insights/components@2020-02-02' = {
  name: name
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
    WorkspaceResourceId: WorkspaceResourceId
  }
}

output name string = appi.name
output id string = appi.id
output instrumentationKey string = appi.properties.InstrumentationKey
