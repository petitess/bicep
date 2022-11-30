targetScope = 'resourceGroup'

param name string
param location string
param privateIPAddress string
param subnetid string
param backendAddressPools array
param probes array

var tags = resourceGroup().tags

resource lb 'Microsoft.Network/loadBalancers@2022-05-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name:  'Standard'
    tier: 'Regional'
      }
  properties: {
    frontendIPConfigurations: [
      {
        name: '${name}-privip'
        properties: {
          privateIPAddress: privateIPAddress
          subnet: {
            id: subnetid
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddressVersion: 'IPv4' 
        }
      }
    ]
    backendAddressPools: [for pool in backendAddressPools: {
      name: pool.name
    }]
    probes: probes
    loadBalancingRules: [
      {
        name: 'lbrule01'
        properties: {
          enableFloatingIP:  false
          enableTcpReset: false
          loadDistribution: 'Default'
          disableOutboundSnat: true
          protocol:  'Tcp'
          backendPort: 80
          frontendPort: 80
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name, '${name}-privip')
          } 
          probe:  {
            id: resourceId('Microsoft.Network/loadBalancers/probes', name, probes[0].name)
          }
          backendAddressPool: {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, backendAddressPools[0].name)
            }
          
        }
      }
    ]
   }
 }

output lbid string = lb.id
output poolid string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, backendAddressPools[0].name)

