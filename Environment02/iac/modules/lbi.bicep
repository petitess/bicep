targetScope = 'resourceGroup'

param name string
param location string
param vdasubnetid string

var tags = union(resourceGroup().tags, {
    Application: 'Citrix'
    Service: 'ADC'
  })
var subnets = [
  {
    id: vdasubnetid
    ip: '10.10.10.100'
  }
  {
    id: vdasubnetid
    ip: '10.10.10.101'
  }
  {
    id: vdasubnetid
    ip: '10.10.10.102'
  }
]
var backendAddressPools = [
  {
    name: 'lbi-adc-pool01'
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

var LbRuleHttps = [for (LbRuleHttps, i) in subnets: {
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
      id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, backendAddressPools[0].name)
    }

  }
}]

resource lb 'Microsoft.Network/loadBalancers@2022-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [for (ipconfig, i) in subnets: {
      name: '${name}-ip${i + 1}'
      properties: {
        privateIPAddress: ipconfig.ip
        privateIPAllocationMethod: 'Static'
        privateIPAddressVersion: 'IPv4'
        subnet: {
          id: ipconfig.id
        }
      }

    }]
    backendAddressPools: backendAddressPools
    probes: probes
    loadBalancingRules: LbRuleHttps
  }
}

output lbid string = lb.id
output poolid string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, backendAddressPools[0].name)
