targetScope = 'resourceGroup'

param name string
param location string
param firstInstance 1 | 4 = 1
param logId string

var tags = union(resourceGroup().tags, {
  Application: 'Citrix'
  Service: 'ADC'
})
param pipCount (6 | 3) = firstInstance == 1 ? 3 : 3
var backendAddressPools = [
  {
    name: 'lb-adc-pool01'
  }
  {
    name: 'lb-adc-pool02'
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

var LbRuleHttp = [
  for (LbRuleHttp, i) in range(firstInstance == 4 ? 3 : 0, pipCount): {
    name: 'lb-rule-http0${i + firstInstance}'
    properties: {
      enableFloatingIP: true
      enableTcpReset: false
      loadDistribution: 'Default'
      protocol: 'Tcp'
      backendPort: 80
      frontendPort: 80
      frontendIPConfiguration: {
        id: resourceId(
          'Microsoft.Network/loadBalancers/frontendIPConfigurations',
          name,
          '${name}-pip${i + firstInstance}'
        )
      }
      probe: {
        id: resourceId('Microsoft.Network/loadBalancers/probes', name, probes[0].name)
      }
      backendAddressPool: {
        id: resourceId(
          'Microsoft.Network/loadBalancers/backendAddressPools',
          name,
          LbRuleHttp == 0 || LbRuleHttp == 1 || LbRuleHttp == 2
            ? backendAddressPools[0].name
            : backendAddressPools[1].name
        )
      }
    }
  }
]

var LbRuleHttps = [
  for (LbRuleHttps, i) in range(firstInstance == 4 ? 3 : 0, pipCount): {
    name: 'lb-rule-https0${i + firstInstance}'
    properties: {
      enableFloatingIP: true
      enableTcpReset: false
      loadDistribution: 'Default'
      protocol: 'Tcp'
      backendPort: 443
      frontendPort: 443
      frontendIPConfiguration: {
        id: resourceId(
          'Microsoft.Network/loadBalancers/frontendIPConfigurations',
          name,
          '${name}-pip${i + firstInstance}'
        )
      }
      probe: {
        id: resourceId('Microsoft.Network/loadBalancers/probes', name, probes[0].name)
      }
      backendAddressPool: {
        id: resourceId(
          'Microsoft.Network/loadBalancers/backendAddressPools',
          name,
          LbRuleHttps == 0 || LbRuleHttps == 1 || LbRuleHttps == 2
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
  dependsOn: [
    pip
  ]
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      for (ipconfig, i) in range(0, pipCount): {
        name: '${name}-pip${i + firstInstance}'
        properties: {
          publicIPAddress: {
            id: pip[i].id
          }
        }
      }
    ]
    backendAddressPools: backendAddressPools
    probes: probes
    loadBalancingRules: concat(LbRuleHttp, LbRuleHttps)
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2024-05-01' = [
  for (pip, i) in range(0, pipCount): {
    name: '${name}-pip${i + firstInstance}'
    location: location
    tags: tags
    sku: {
      name: 'Standard'
    }
    properties: {
      publicIPAllocationMethod: 'Static'
      dnsSettings: {
        domainNameLabel: '${replace(name, '-', '')}${i + firstInstance}'
      }
    }
  }
]

resource diagPip 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (d, i) in range(0, pipCount): {
    name: 'diag-pip'
    scope: pip[i]
    properties: {
      workspaceId: logId
      logs: [
        for c in items({ DDoSProtectionNotifications: true, DDoSMitigationFlowLogs: true, DDoSMitigationReports: true }): {
          category: c.key
          enabled: c.value
        }
      ]
    }
  }
]

resource lock 'Microsoft.Authorization/locks@2020-05-01' = [
  for (lock, i) in range(0, pipCount): if (false) {
    name: 'dontdelete-pip'
    scope: pip[i]
    properties: {
      level: 'CanNotDelete'
    }
  }
]

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
