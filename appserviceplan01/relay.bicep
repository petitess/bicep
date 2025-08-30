param relayName string
param location string = resourceGroup().location
param relayConnectionName string
param relayRuleName string
param snetPepId string?
param privateDnsZoneId string?
param ipAddress string?
param workspaceId string?

resource relay 'Microsoft.Relay/namespaces@2024-01-01' = {
  name: relayName
  location: location
}

resource hybrid_con 'Microsoft.Relay/namespaces/hybridConnections@2024-01-01' = {
  name: relayConnectionName
  parent: relay
}

resource relay_rule 'Microsoft.Relay/namespaces/authorizationRules@2024-01-01' = {
  name: relayRuleName
  parent: relay
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2024-07-01' = if (snetPepId != null) {
  name: 'pep-${relayName}'
  location: location
  properties: {
    customNetworkInterfaceName: 'nic-${relayName}'
    privateLinkServiceConnections: [
      {
        name: 'A'
        properties: {
          privateLinkServiceId: relay.id
          groupIds: [
            'namespace'
          ]
        }
      }
    ]
    subnet: {
      id: snetPepId
    }
    ipConfigurations: [
      {
        name: 'config'
        properties: {
          privateIPAddress: ipAddress
          groupId: 'namespace'
          memberName: 'namespace'
        }
      }
    ]
  }
}

resource pepDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-07-01' = if (snetPepId != null) {
  name: 'default'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-servicebus-windows-net'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(workspaceId)) {
  name: 'diag-${relayRuleName}'
  scope: relay
  properties: {
    workspaceId: workspaceId
    logs: [
      for c in items({ HybridConnectionsEvent: true, VNetAndIPFilteringLogs: true }): {
        category: c.key
        enabled: c.value
      }
    ]
  }
}

output conectionId string = relay.id
output keyName1 string = relay_rule.listKeys().keyName
output keyValue1 string = relay_rule.listKeys().primaryKey
