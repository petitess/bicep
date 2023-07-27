targetScope = 'resourceGroup'

param env string
param location string

var tags = resourceGroup().tags
var customDomain = 'gtm.company.se'
var certName = 'cert-app-gtm-2023'

resource asp 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'asp-${env}-01'
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  properties: {
    reserved: true
    zoneRedundant: false

  }
}

resource app 'Microsoft.Web/sites@2022-09-01' = {
  name: 'app-gma-${env}-01'
  location: location
  tags: tags
  properties: {
    serverFarmId: asp.id
    clientAffinityEnabled: false
    httpsOnly: true
    hostNameSslStates: [
      {
        name: customDomain
        hostType: 'Standard'
        sslState: 'SniEnabled'
        thumbprint: cert.properties.thumbprint

      }
    ]
    siteConfig: {
      linuxFxVersion: 'DOCKER|gcr.io/cloud-tagging-10302018/gtm-cloud-image:stable'
      appCommandLine: ''
      alwaysOn: true
      ftpsState: 'FtpsOnly'
      appSettings: []
    }
  }
}

resource cert 'Microsoft.Web/certificates@2022-09-01' = {
  name: certName
  location: location
  tags: {
    Application: 'Google Tag Manager'
    Environment: 'Production'
  }
  properties: {
    serverFarmId: asp.id
    canonicalName: customDomain
    hostNames: [
      customDomain
    ]
  }
}

resource hostName 'Microsoft.Web/sites/hostNameBindings@2022-09-01' = {
  name: customDomain
  parent: app
  properties: {
    siteName: app.name
    hostNameType: 'Verified'
    sslState: 'SniEnabled'
    thumbprint: cert.properties.thumbprint
  }
}
