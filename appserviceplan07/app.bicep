targetScope = 'resourceGroup'

param affix string
param location string
param virtualNetworkSubnetId string
param snetPepId string

var tags = resourceGroup().tags
var customDomain = 'appx.domain.se'
var certName = 'domainse'
var certInstalled = false

resource asp 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'asp-app-${affix}-01'
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

resource app 'Microsoft.Web/sites@2022-09-01' = {
  name: 'app-${affix}-01'
  location: location
  tags: tags
  properties: {
    serverFarmId: asp.id
    publicNetworkAccess: 'Disabled'
    virtualNetworkSubnetId: virtualNetworkSubnetId
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2023-02-01' = {
  name: 'pep-${app.name}'
  location: location
  tags: tags
  properties: {
    customNetworkInterfaceName: 'nic-${app.name}'
    subnet: {
      id: snetPepId
    }
    privateLinkServiceConnections: [
      {
        name: app.name
        properties: {
          privateLinkServiceId: app.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource cert 'Microsoft.Web/certificates@2022-09-01' = if(certInstalled) {
  name: certName
  location: location
  tags: tags
  properties: {
    serverFarmId: asp.id
    hostNames: [
      customDomain
    ]
    keyVaultId: kv.id
    keyVaultSecretName: certName
  }
}

resource hostName 'Microsoft.Web/sites/hostNameBindings@2022-09-01' = if(certInstalled) {
  name: customDomain
  parent: app
  properties: {
    siteName: app.name
    hostNameType: 'Verified'
    sslState: 'SniEnabled'
    thumbprint: cert.properties.thumbprint
  }
}

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: 'kv-${affix}-01'
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: false
    enabledForTemplateDeployment: true
    accessPolicies: [
      {
        objectId: '2d0abffa-b360-4f2f-9478-xxxx' //Microsoft Azure App Service
        permissions: {
          certificates: [
            'get'
          ]
          secrets: [
            'get'
          ]
          keys: [
            'get'
          ]
        }
        tenantId: tenant().tenantId
      }
    ]
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: []
    }
  }
}

