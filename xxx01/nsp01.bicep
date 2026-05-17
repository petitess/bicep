param name string
param location string

resource nsp 'Microsoft.Network/networkSecurityPerimeters@2025-05-01' = {
  name: name
  location: location
  properties: {}
}

resource profile 'Microsoft.Network/networkSecurityPerimeters/profiles@2025-05-01' = {
  name: 'profile'
  parent: nsp
  properties: {}
}

resource inbound 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2025-05-01' = {
  name: 'inbound'
  parent: profile
  properties: {
    direction: 'Inbound'
    addressPrefixes: [
      '1.1.1.1/32'
      '1.150.118.1/32'
    ]
  }
}

resource inbound2 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2025-05-01' = {
  name: 'inbound2'
  parent: profile
  properties: {
    direction: 'Inbound'
    serviceTags: [
      'AzureDatabricksServerless'
    ]
  }
}

resource inbound3 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2025-05-01' = {
  name: 'inbound3'
  parent: profile
  properties: {
    direction: 'Inbound'
    subscriptions: [
      {
        id: '/subscriptions/${subscription().subscriptionId}'
      }
    ]
  }
}

resource outboud 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2025-05-01' = {
  name: 'outbound'
  parent: profile
  properties: {
    direction: 'Outbound'
    fullyQualifiedDomainNames: [
      'www.youtube.com'
    ]
  }
}

resource link 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2025-05-01' = {
  name: 'storage'
  parent: nsp
  properties: {
    accessMode: 'Enforced'
    profile: {
      id: profile.id
    }
    privateLinkResource: {
      id: resourceId(
        subscription().subscriptionId,
        'rg-stcostmanagment01',
        'Microsoft.Storage/storageAccounts',
        'stcostmanagment01'
      )
    }
  }
}
//no support for function apps
resource func 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2025-05-01' = if (false) {
  name: 'func'
  parent: nsp
  properties: {
    accessMode: 'Enforced'
    profile: {
      id: profile.id
    }
    privateLinkResource: {
      id: resourceId(subscription().subscriptionId, 'rg-func', 'Microsoft.Web/sites', 'func-api-call')
    }
  }
}
