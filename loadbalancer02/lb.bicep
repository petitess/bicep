targetScope = 'resourceGroup'

param name string
param location string
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
        name: '${name}-pip'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
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
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name, '${name}-pip')
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
    outboundRules: [
      {
        name: 'Internet'
        properties: {
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, backendAddressPools[0].name)
          }
          frontendIPConfigurations: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name, '${name}-pip')
            }
          ]
          protocol: 'All'
          allocatedOutboundPorts: 800
        }
      }
    ]
   }
 }

 resource pip 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: 'pip-${name}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

output lbid string = lb.id
output poolid string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, backendAddressPools[0].name)

