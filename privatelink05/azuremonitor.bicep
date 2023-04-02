param tags object = resourceGroup().tags
param location string
param logId string
param appiId string
param snetId string

var pdnsz = [
  'privatelink.monitor.azure.com'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.agentsvc.azure-automation.net'
  'privatelink.blob.${environment().suffixes.storage}'
]

resource pl 'microsoft.insights/privateLinkScopes@2021-07-01-preview' = {
  name: 'pl-azuremonitor-01'
  location: 'global'
  tags: tags
  properties: {
    accessModeSettings: {
      ingestionAccessMode: 'PrivateOnly'
      queryAccessMode: 'PrivateOnly'
      exclusions: []
    }
  }
}

resource plLog 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  name: uniqueString(logId)
  parent: pl
  properties: {
    linkedResourceId: logId
  }
}

resource plAppi 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  name: uniqueString(appiId)
  parent: pl
  properties: {
    linkedResourceId: appiId
  }
}

resource monitor 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: 'pe-azuremonitor-01'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-pe-azuremonitor-01'
    privateLinkServiceConnections: [
      {
        name: pl.name
        properties: {
          privateLinkServiceId: pl.id
          groupIds: [
            'azuremonitor'
          ]
        }
      }
    ]
    subnet: {
      id: snetId
    }
  }
}

resource pdnszg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = {
  name: 'default'
  parent: monitor
  properties: {
    privateDnsZoneConfigs: [for dns in pdnsz: {
        name: dns
        properties: {
          privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', dns)
        }
    }]
  }
}

output azureMonitorPlName string = pl.name
