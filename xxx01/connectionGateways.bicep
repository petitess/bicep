param connectionName string
param displayName string
param gatewayResourceGroup string
param gatewayName string
param connectorName string
param location string = resourceGroup().location

resource connector 'Microsoft.Web/customApis@2016-06-01' existing = {
  name: connectorName
}

resource gatewayApi 'Microsoft.Web/connectionGateways@2016-06-01' existing = {
  name: gatewayName
  scope: resourceGroup(gatewayResourceGroup)
}

resource apiConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: connectionName
  location: location
  properties: {
    displayName: displayName
    parameterValues: {
      authType: 'anonymous'
#disable-next-line BCP036
      gateway: {
        name: gatewayName
        id: gatewayApi.id
        type: 'Microsoft.Web/connectionGateways'
      }
    }
    api: {
      name: connector.name
      displayName: 'CONNECTOR ${connectorName}'
      id: connector.id
      type: 'Microsoft.Web/customApis'
    }
  }
}
