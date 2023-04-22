param tags object = resourceGroup().tags
param vnetId string
param location string
param snetId string
param logId string
param appiId string

var pdnsz = [
  'privatelink.monitor.azure.com'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.agentsvc.azure-automation.net'
  'privatelink.blob.${environment().suffixes.storage}'
]

resource plDns 'Microsoft.Network/privateDnsZones@2020-06-01' = [for dns in pdnsz: {
  name: dns
  location: 'global'
  tags: tags
}]

resource linkdns 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (dns, i) in pdnsz:  {
  name: 'link-${dns}'
  parent: plDns[i]
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

resource pl 'microsoft.insights/privateLinkScopes@2021-07-01-preview' = {
  name: 'pl-azuremonitor-01'
  location: 'global'
  tags: tags
  properties: {
    accessModeSettings: {
      ingestionAccessMode: 'PrivateOnly'
      queryAccessMode: 'PrivateOnly'
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

resource monitor 'Microsoft.Network/privateEndpoints@2022-09-01' = {
  name: 'pep-azuremonitor-01'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-pep-azuremonitor-01'
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

resource pdnszg 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = {
  name: 'default'
  parent: monitor
  properties: {
    privateDnsZoneConfigs: [for (dns, i) in pdnsz: {
      name: dns
      properties: {
        //privateDnsZoneId: plDns[i].id
        privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', dns)
      }
    }]
  }
}
