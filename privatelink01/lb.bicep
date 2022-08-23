targetScope = 'resourceGroup'

param name string
param location string
param privateIPAddress string
param subnetid string
param backendAddressPools array
param probes array

var tags = resourceGroup().tags

resource lb 'Microsoft.Network/loadBalancers@2022-01-01' = {
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
      properties: pool.properties
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
            id: '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${name}/frontendIPConfigurations/${name}-privip'
          } 
          probe:  {
            id: '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${name}/probes/${probes[0].name}'
          }
          backendAddressPool: {
              id: '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${name}/backendAddressPools/${backendAddressPools[0].name}'
            }
          
        }
      }
    ]
    
   }
 }

resource lbpools 'Microsoft.Network/loadBalancers/backendAddressPools@2022-01-01' = [for pool in backendAddressPools: {
  name: pool.name
  parent: lb
  properties: pool.properties 
}]

resource pl 'Microsoft.Network/privateLinkServices@2022-01-01' = {
  name: 'pl-${name}'
  location: location
  tags: tags
  properties: {
    loadBalancerFrontendIpConfigurations: [
      {
        id: lb.properties.frontendIPConfigurations[0].id
        name: lb.properties.frontendIPConfigurations[0].name
        properties: {
          privateIPAddress: lb.properties.frontendIPConfigurations[0].properties.privateIPAddress
        }
      }
    ]
    ipConfigurations: [
      {
        name: 'pl-ipconfig'
        properties: {
          subnet: {
            id: lb.properties.frontendIPConfigurations[0].properties.subnet.id
          }
        }
      }
    ]
  }
}

output lbid string = lb.id
output plid string = pl.id
