targetScope = 'resourceGroup'

param affix string 
param name string
param location string
param vnetname string
var pipcount = 3

var tags = resourceGroup().tags

resource firewall 'Microsoft.Network/azureFirewalls@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      tier: 'Standard'
    }
    firewallPolicy: {
      id: firewallPolicy.id
    }
    ipConfigurations: [for (ipconfig, i) in range(0, pipcount): {
      name: '${name}-pip${i + 1}'
      properties: {
        subnet: pip[i].name == '${name}-pip1' ? {
          id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, 'AzureFirewallSubnet')
        } : null
        publicIPAddress: {
          id: pip[i].id
        }
      }
      }]
  }
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-07-01' = {
  name: 'afwp-${affix}-01'
  location: location
  tags: tags
  properties: {
    sku: {
      tier: 'Standard'
    }
  }
}

resource RuleGroup01 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-07-01' = {
  name: replace(subscription().displayName, ' ', '')
  parent: firewallPolicy
  properties: {
   priority: 60000
   ruleCollections: [
    {
      name: 'ApplicationRule01'
      priority: 50000
      ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
      action: {
       type: 'Deny'
      }
      rules: [
       {
        name: 'BlockGambling'
        ruleType: 'ApplicationRule'
        terminateTLS: false
        protocols: [
          {
            port: 443
            protocolType: 'Https'
          }
          {
            port: 80
            protocolType: 'Http'
          }
        ]
        webCategories: [
          'gambling'
          'news'
        ]
        sourceAddresses: [
          '*'
        ]
       } 
       
      ] 
    }
    {
      name: 'NetworkRule01'
      priority: 25000
      ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
      action: {
       type: 'Allow'
      }
      rules: [
       {
        name: 'AllowHttps'
        ruleType: 'NetworkRule'
        sourceAddresses: [
          '*'
        ]
        destinationAddresses: [
          '*'
        ]
        destinationPorts: [
          '443'
        ]
        ipProtocols: [
          'Any'
        ]
       } 
      ] 
    }
    {
      name: 'NatRule02'
      ruleCollectionType:  'FirewallPolicyNatRuleCollection'
      action: {
        type: 'DNAT'
      }
      priority: 20000
      rules: [
        {
          name: 'AllowSite01'
          ruleType: 'NatRule'
          sourceAddresses: [
            '*'
          ]
          ipProtocols: [
            'TCP'
            'UDP'
          ]
          destinationPorts: [
            '80'
          ]
          destinationAddresses: [
           pip[0].properties.ipAddress
          ]
          translatedPort: '80'
          translatedFqdn: 'server1.agw.domain.com'
        }
        {
          name: 'AllowSite02'
          ruleType: 'NatRule'
          sourceAddresses: [
            '*'
          ]
          ipProtocols: [
            'TCP'
            'UDP'
          ]
          destinationPorts: [
            '80'
          ]
          destinationAddresses: [
           pip[1].properties.ipAddress
          ]
          translatedPort: '80'
          translatedFqdn: 'server2.agw.domain.com'
        }
      ]
    }
   ] 
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

