targetScope = 'resourceGroup'

param location string
param tags object = resourceGroup().tags
param rgpename string
param plname string
param vnetname string
param subnetname string
param blobdns string
param monitordns string
param omsdns string
param odsdns string
param agentsvcdns string

resource monitor 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: 'pe-azuremonitor-01'
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: plname
        properties: {
          privateLinkServiceId: resourceId(rgpename, 'Microsoft.insights/privateLinkScopes', plname)
          groupIds: [
            'azuremonitor'
          ]
        }
      }
    ]
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, subnetname)
    }
  }
}

resource dnsblob 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = {
  name: 'default'
  parent: monitor
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-monitor-azure-com'
        properties: {
          privateDnsZoneId: monitordns
        }
      }
      {
        name: 'privatelink-oms-opinsights-azure-com'
        properties: {
          privateDnsZoneId: omsdns
        }
      }
      {
        name: 'privatelink-ods-opinsights-azure-com'
        properties: {
          privateDnsZoneId: odsdns
        }
      }
      {
        name: 'privatelink-agentsvc-azure-automation-net'
        properties: {
          privateDnsZoneId: agentsvcdns
        }
      }
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
          privateDnsZoneId: blobdns
        }
      }
    ]
  }
}

output pemonitorid string = monitor.id
output pemonitorname string = monitor.name
