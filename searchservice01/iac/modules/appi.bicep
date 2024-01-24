//param workspaceName string
param location string
param name string
param logId string
param tags object = resourceGroup().tags

resource appi 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    WorkspaceResourceId: logId
  }
  tags: tags
}

output logId string = appi.id
