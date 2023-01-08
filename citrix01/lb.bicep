targetScope = 'resourceGroup'

param name string
param location string

var tags = union(resourceGroup().tags, {
    Application: 'Citrix'
    Service: 'ADC'
  })
var pipcount = 3
var backendAddressPools = [
  {
    name: 'lb-adc-pool01'
  }
]
var probes = [
  {
    name: 'lb-probe01'
    properties: {
      port: 9000
      protocol: 'tcp'
      intervalInSeconds: 5
      numberOfProbes: 2
    }
  }
]

var LbRuleHttp = [for (LbRuleHttp, i) in range(0, pipcount): {
  name: 'lb-rule-http0${i + 1}'
  properties: {
    enableFloatingIP: true
    enableTcpReset: false
    loadDistribution: 'Default'
    protocol: 'Tcp'
    backendPort: 80
    frontendPort: 80
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name, '${name}-pip${i + 1}')
    }
    probe: {
      id: resourceId('Microsoft.Network/loadBalancers/probes', name, probes[0].name)
    }
    backendAddressPool: {
      id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, backendAddressPools[0].name)
    }

  }
}]

var LbRuleHttps = [for (LbRuleHttps, i) in range(0, pipcount): {
  name: 'lb-rule-https0${i + 1}'
  properties: {
    enableFloatingIP: true
    enableTcpReset: false
    loadDistribution: 'Default'
    protocol: 'Tcp'
    backendPort: 443
    frontendPort: 443
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name, '${name}-pip${i + 1}')
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
  dependsOn: [
    pip
  ]
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [for (ipconfig, i) in range(0, pipcount): {
      name: '${name}-pip${i + 1}'
      properties: {
        publicIPAddress: {
          id: pip[i].id
        }
      }

    }]
    backendAddressPools: backendAddressPools
    probes: probes
    loadBalancingRules: concat(LbRuleHttp, LbRuleHttps)
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2022-07-01' = [for (pip, i) in range(0, pipcount): {
  name: '${name}-pip${i + 1}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: '${replace(name, '-', '')}${i + 1}'
    }
  }
}]

output lbid string = lb.id
output poolid string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, backendAddressPools[0].name)
