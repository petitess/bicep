param name string
param tags object = resourceGroup().tags
param logId string = ''

resource afd 'Microsoft.Cdn/profiles@2024-02-01' = {
  name: name
  location: 'Global'
  tags: tags
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  // identity: {
  //   type: 'UserAssigned'
  //   userAssignedIdentities: {
  //     '${id.id}': {}
  //   }
  // }
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logId)) {
  name: 'diag-${name}'
  scope: afd
  properties: {
    workspaceId: logId
    logs: [
      {
        enabled: true
        category: 'FrontDoorAccessLog'
      }
      {
        enabled: true
        category: 'FrontDoorHealthProbeLog'
      }
      {
        enabled: true
        category: 'FrontDoorWebApplicationFirewallLog'
      }
    ]
  }
}
