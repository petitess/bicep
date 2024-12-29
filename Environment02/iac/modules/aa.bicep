targetScope = 'resourceGroup'

param name string
param location string
@description('UTC, Date dd/mm/yyy')
param basedate string = utcNow('d')
@description('W. Europe Standard Time, hh:mm')
param basetime string = dateTimeAdd(utcNow(), 'PT2H', 't')
param privateEndpoints ({ Webhook: string?, DSCAndHybridWorker: string? })
param vnetRg string
param vnetName string
param dnsRg string

var tags = resourceGroup().tags

resource aa 'Microsoft.Automation/automationAccounts@2023-11-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

resource pepR 'Microsoft.Network/privateEndpoints@2024-01-01' = [
  for pep in items(privateEndpoints): {
    name: toLower('pep-${name}-${pep.key}')
    location: location
    properties: {
      customNetworkInterfaceName: toLower('nic-${name}-${pep.key}')
      ipConfigurations: [
        {
          name: 'config-${pep.key}'
          properties: {
            privateIPAddress: pep.value
            groupId: pep.key
            memberName: pep.key
          }
        }
      ]
      privateLinkServiceConnections: [
        {
          name: '${aa.name}-${pep.key}'
          properties: {
            privateLinkServiceId: aa.id
            groupIds: [
              pep.key
            ]
          }
        }
      ]
      subnet: {
        id: resourceId(vnetRg, 'Microsoft.Network/virtualNetworks/subnets', vnetName, 'snet-pep')
      }
    }
  }
]

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = [
  for (pep, i) in items(privateEndpoints): {
    name: 'default'
    parent: pepR[i]
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-${pep.key}-core-windows-net'
          properties: {
            privateDnsZoneId: resourceId(
              dnsRg,
              'Microsoft.Network/privateDnsZones',
              'privatelink.azure-automation.net'
            )
          }
        }
      ]
    }
  }
]

output id string = aa.id
output name string = aa.name
output principalId string = aa.identity.principalId
output basedate string = basedate
output basetime string = basetime
