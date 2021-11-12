//Parametar för Azure SQL
param serverName string = uniqueString('sql', resourceGroup().id)
param sqlDBName string = 'SampleDB'
param location string = resourceGroup().location
param administratorLogin string = 'karol'
param privateEndpointName string = 'Endpointb3'
//@secure()
param administratorLoginPassword string = '12345678.abc'

param vnetName string = 'JasonsVnets'
param subnetName string = 'B3CARE-SE-DB'
var VnetPath = '${resourceGroup().id}/providers/Microsoft.Network/virtualNetworks/${vnetName}'
var subnetRef = '${VnetPath}/subnets/${subnetName}'

resource server 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    publicNetworkAccess: 'Disabled'
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2021-05-01-preview' = {
  name: '${server.name}/${sqlDBName}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    //storageAccountType: 'LRS'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id:  subnetRef
    }
    privateLinkServiceConnections: [
      {
        name: 'MyConnection'
        properties: {
          privateLinkServiceId: server.id
         groupIds: [
             'sqlserver'
          ]
          
        }
      }
    ]
  }
}

