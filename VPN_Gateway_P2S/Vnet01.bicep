//targetScope = 'subscription'


param VnetName string = 'vnet-dev-01'

param locationRG string = resourceGroup().location 

output SubnetAD string = virtualNetwork.properties.subnets[0].id
output SubnetDB string = virtualNetwork.properties.subnets[1].id
output SubnetAPP string = virtualNetwork.properties.subnets[2].id
output GatewaySubnet string = virtualNetwork.properties.subnets[3].id

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: VnetName
  location: locationRG
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
        
      ]
    }
    enableVmProtection: false
    enableDdosProtection: false
    subnets: [
      {
        name: 'SUB-SE-AD'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'SUB-SE-DB'
        properties: {
          addressPrefix: '10.0.2.0/24'
           privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'SUB-SE-APP'
        properties: {
          addressPrefix: '10.0.3.0/24'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.4.0/24'
        }
      }
      
    ]
  }
}

