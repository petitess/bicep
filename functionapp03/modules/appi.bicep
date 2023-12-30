param location string
param tags object = resourceGroup().tags
param WorkspaceResourceId string = ''

resource appi 'Microsoft.Insights/components@2020-02-02' = if (!empty(WorkspaceResourceId)) {
  name: 'appi'
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Request_Source: 'IbizaWebAppExtensionCreate'
    Flow_Type: 'Redfield'
    Application_Type: 'web'
    WorkspaceResourceId: WorkspaceResourceId
  }
}

output id string = appi.id
