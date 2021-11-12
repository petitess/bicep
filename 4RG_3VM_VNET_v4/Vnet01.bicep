//targetScope = 'subscription'


param VnetName string = 'vnet-dev-01'

param locationRG string = resourceGroup().location 

output SubnetAD string = virtualNetwork.properties.subnets[0].id
output SubnetDB string = virtualNetwork.properties.subnets[1].id
output SubnetCTX string = virtualNetwork.properties.subnets[2].id
output SubnetAPP string = virtualNetwork.properties.subnets[3].id
output SubnetMGT string = virtualNetwork.properties.subnets[4].id
output SubnetWEB string = virtualNetwork.properties.subnets[5].id
output SubnetDMZ string = virtualNetwork.properties.subnets[6].id
output SubnetBAK string = virtualNetwork.properties.subnets[7].id

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: VnetName
  location: locationRG
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/8'
        
      ]
    }
    enableVmProtection: false
    enableDdosProtection: false
    subnets: [
      {
        name: 'B3CARE-SE-AD'
        properties: {
          addressPrefix: '10.112.0.0/21'
        }
      }
      {
        name: 'B3CARE-SE-DB'
        properties: {
          addressPrefix: '10.112.8.0/24'
           privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'B3CARE-SE-CTX'
        properties: {
          addressPrefix: '10.112.16.0/21'
          
        }
      }
      {
        name: 'B3CARE-SE-APP'
        properties: {
          addressPrefix: '10.112.24.0/21'
        }
      }
      {
        name: 'B3CARE-SE-MGT'
        properties: {
          addressPrefix: '10.112.32.0/21'
        }
      }
      {
        name: 'B3CARE-SE-WEB'
        properties: {
          addressPrefix: '10.112.40.0/21'
        }
      }
      {
        name: 'B3CARE-SE-DMZ'
        properties: {
          addressPrefix: '10.112.48.0/21'
        }
      }
      {
        name: 'B3CARE-SE-BAC'
        properties: {
          addressPrefix: '10.112.56.0/21'
        }
      }
    ]
  }
}

