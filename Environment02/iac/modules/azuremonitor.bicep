param location string
param tags object = resourceGroup().tags
param snetId string
param dnsRg string
param name string
param logId string
param dceId string
param appiId string

var pdnsz = [
  'privatelink.monitor.azure.com'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.agentsvc.azure-automation.net'
  'privatelink.blob.${environment().suffixes.storage}'
]

resource pl 'microsoft.insights/privateLinkScopes@2021-07-01-preview' = {
  name: name
  location: 'global'
  tags: tags
  properties: {
    accessModeSettings: {
      ingestionAccessMode: 'PrivateOnly'
      queryAccessMode: 'Open'
      exclusions: []
    }
  }
}

resource pepMonitor 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: 'pep-${name}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-${name}'
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

resource pdnszg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  name: 'default'
  parent: pepMonitor
  dependsOn: [
    plAppi
    plDce
    plLog
  ]
  properties: {
    privateDnsZoneConfigs: [
      for (dns, i) in pdnsz: {
        name: dns
        properties: {
          privateDnsZoneId: resourceId(dnsRg, 'Microsoft.Network/privateDnsZones', dns)
        }
      }
    ]
  }
}

resource plLog 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  name: uniqueString(logId)
  parent: pl
  properties: {
    linkedResourceId: logId
  }
}

resource plDce 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  name: uniqueString(dceId)
  parent: pl
  properties: {
    linkedResourceId: dceId
  }
}

resource plAppi 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  name: uniqueString(appiId)
  parent: pl
  properties: {
    linkedResourceId: appiId
  }
}
