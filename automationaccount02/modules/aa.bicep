targetScope = 'resourceGroup'

param name string
param location string
@description('UTC, Date dd/mm/yyy')
param basedate string = utcNow('d')
@description('W. Europe Standard Time, hh:mm')
param basetime string = dateTimeAdd(utcNow(), 'PT2H', 't')
param privateEndpoints ({ Webhook: string?, DSCAndHybridWorker: string? })
param vnetRg string = ''
param vnetName string = ''
param dnsRg string = ''
param utc string = utcNow()

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

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2023-11-01' = {
  name: 'run-restart-app-gtm'
  location: location
  parent: aa
  properties: {
    runbookType: 'PowerShell72'
    publishContentLink: {
      uri: 'https://raw.githubusercontent.com/petitess/powershell/refs/heads/main/Runbooks/run-restart-app-gtm.ps1'
    }
  }
}

resource webhook 'Microsoft.Automation/automationAccounts/webhooks@2015-10-31' = {
  name: 'restart-gtm'
  parent: aa
  properties: {
    isEnabled: true
    parameters: {}
    expiryTime: dateTimeAdd(utc, 'P9Y')
    runbook: {
      name: runbook.name
    }
  }
}

resource pepR 'Microsoft.Network/privateEndpoints@2024-05-01' = [
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

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = [
  for (pep, i) in items(privateEndpoints): {
    name: 'default'
    parent: pepR[i]
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-${pep.key}-core-windows-net'
          properties: {
            privateDnsZoneId: resourceId(dnsRg, 'Microsoft.Network/privateDnsZones', 'privatelink.azure-automation.net')
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
output webhookId string = webhook.id
//Bug, output disapears, workaround is to hardcode
output webhookUrl string = 'https://841a5de7-69c6-47e0-903e-e18859a9ae0e.webhook.we.azure-automation.net/webhooks?token=a5fLxv7WswN6oVTWmEqeTQQCLFt02Na4OdaLT24ZWG8%3d'
