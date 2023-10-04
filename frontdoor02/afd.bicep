param name string
param tags object = resourceGroup().tags
param logId string = ''

resource afd 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: name
  location: 'Global'
  tags: tags
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(!empty(logId)) {
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
