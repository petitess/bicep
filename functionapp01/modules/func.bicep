param name string
param kind 'functionapp,linux' | 'functionapp'
param funcAppServicePlanId string
param snetOutboundId string
param appiConnectionString string
param defaultEndpointsProtocol string
param appSettings array = []
param snetPepId string = ''
param rgDns string = ''

var funcAppSettings = union(appSettings, [
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appiConnectionString
  }
  {
    name: 'AzureWebJobsDashboard'
    value: defaultEndpointsProtocol
  }
  {
    name: 'AzureWebJobsStorage'
    value: defaultEndpointsProtocol
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: 'dotnet-isolated'
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: defaultEndpointsProtocol
  }
  {
    name: 'WEBSITE_CONTENTOVERVNET'
    value: '1'
  }

  {
    name: 'WEBSITE_CONTENTSHARE'
    value: 'func01'
  }
  {
    name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
    value: '1'
  }
  {
    name: 'WEBSITE_RUN_FROM_PACKAGE'
    value: kind == 'functionapp,linux' ? '1' : '0'
  }
])

resource func 'Microsoft.Web/sites@2023-12-01' = {
  name: name
  location: resourceGroup().location
  tags: resourceGroup().tags
  kind: kind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: funcAppServicePlanId
    reserved: kind == 'functionapp,linux' ? true : false
    siteConfig: {
      alwaysOn: true
      minTlsVersion: '1.2'
      http20Enabled: true
      appSettings: funcAppSettings
      linuxFxVersion: kind == 'functionapp,linux' ? 'DOTNET-ISOLATED|8.0' : null
      netFrameworkVersion: 'v8.0'
      use32BitWorkerProcess: kind == 'functionapp,linux' ? false : true
    }
    publicNetworkAccess: 'Disabled'
    virtualNetworkSubnetId: snetOutboundId
    vnetRouteAllEnabled: true
    httpsOnly: true
  }
}

resource pep 'Microsoft.Network/privateEndpoints@2023-11-01' = if (!empty(snetPepId)) {
  name: 'pep-${name}'
  location: resourceGroup().location
  tags: resourceGroup().tags
  properties: {
    customNetworkInterfaceName: 'nic-${name}'
    subnet: {
      id: snetPepId
    }
    privateLinkServiceConnections: [
      {
        name: name
        properties: {
          privateLinkServiceId: func.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = if (!empty(snetPepId)) {
  name: 'dns-${name}'
  parent: pep
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'pep'
        properties: {
          privateDnsZoneId: resourceId(rgDns, 'Microsoft.Network/privateDnsZones', 'privatelink.azurewebsites.net')
        }
      }
    ]
  }
}
