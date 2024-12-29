targetScope = 'resourceGroup'

param name string
param location string
param vnetrg string
param vnetname string

var tags = union(resourceGroup().tags, {
  Application: 'Citrix'
  Service: 'ADC'
})
var subnets = [
  {
    name: 'snet-vda'
    ip: '10.10.10.100'
    description: 'StoreFront - vmadcprod01/02'
  }
  {
    name: 'snet-vda'
    ip: '10.10.10.101'
    description: 'DNS/LDAP - vmadcprod01/02'
  }
  {
    name: 'snet-vda'
    ip: '10.10.10.102'
    description: 'Gateway Callback server - vmadcprod01/02'
  }
  // {
  //   name: 'snet-vda'
  //   ip: '10.10.10.103'
  //   description: 'StoreFront - vmadcprod03/04'
  // }
  // {
  //   name: 'snet-vda'
  //   ip: '10.10.10.104'
  //   description: 'DNS/LDAP - vmadcprod03/04'
  // }
  // {
  //   name: 'snet-vda'
  //   ip: '10.10.10.105'
  //   description: 'Gateway Callback server - vmadcprod03/04'
  // }
]
var backendAddressPools = [
  {
    name: 'lbi-adc-pool01'
  }
  {
    name: 'lbi-adc-pool02'
  }
]
var probes = [
  {
    name: 'lbi-probe01'
    properties: {
      port: 9000
      protocol: 'tcp'
      intervalInSeconds: 5
      numberOfProbes: 2
    }
  }
]

var LbRuleHttps = [
  for (LbRuleHttps, i) in subnets: {
    name: 'lbi-rule-https0${i + 1}'
    properties: {
      enableFloatingIP: true
      enableTcpReset: false
      loadDistribution: 'Default'
      protocol: 'Tcp'
      backendPort: 443
      frontendPort: 443
      frontendIPConfiguration: {
        id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name, '${name}-ip${i + 1}')
      }
      probe: {
        id: resourceId('Microsoft.Network/loadBalancers/probes', name, probes[0].name)
      }
      backendAddressPool: {
        id: resourceId(
          'Microsoft.Network/loadBalancers/backendAddressPools',
          name,
          contains(LbRuleHttps.ip, '100') || contains(LbRuleHttps.ip, '101') || contains(LbRuleHttps.ip, '102')
            ? backendAddressPools[0].name
            : backendAddressPools[1].name
        )
      }
    }
  }
]

resource lb 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      for (ipconfig, i) in subnets: {
        name: '${name}-ip${i + 1}'
        properties: {
          privateIPAddress: ipconfig.ip
          privateIPAllocationMethod: 'Static'
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: resourceId(vnetrg, 'Microsoft.Network/virtualNetworks/subnets', vnetname, ipconfig.name)
          }
        }
      }
    ]
    backendAddressPools: backendAddressPools
    probes: probes
    loadBalancingRules: LbRuleHttps
  }
}

output lbid string = lb.id
output poolid string = resourceId(
  'Microsoft.Network/loadBalancers/backendAddressPools',
  name,
  backendAddressPools[0].name
)
output poolidX string = resourceId(
  'Microsoft.Network/loadBalancers/backendAddressPools',
  name,
  backendAddressPools[1].name
)
