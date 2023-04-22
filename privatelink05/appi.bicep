targetScope = 'resourceGroup'

param name string
param location string
param WorkspaceResourceId string

var tags = resourceGroup().tags

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
    RetentionInDays: 90
    WorkspaceResourceId: WorkspaceResourceId
  }
}

output id string = appi.id
output ConnectionString string = appi.properties.ConnectionString
