targetScope = 'resourceGroup'

param affix string 
param location string
param subnet string

var tags = resourceGroup().tags

resource firewall 'Microsoft.Network/azureFirewalls@2022-07-01' existing = {
  name: 'afw-${affix}-01'
}

// resource firewall 'Microsoft.Network/azureFirewalls@2022-07-01' = {
//   name: 'afw-${affix}-01'
//   location: location
//   tags: tags
//   properties: {
//     sku: {
//       tier: 'Standard'
//     }
//     firewallPolicy: {
//       id: firewallPolicy.id
//     }
//     ipConfigurations: [
//       {
//         name: pip.name
//         properties: {
//           subnet: {
//             id: subnet
//           }
//           publicIPAddress: {
//             id: pip.id
//           }
//         }
//       }
//     ]
//   }
// }

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
  name: 'ApplicationGroup01'
  parent: firewallPolicy
  properties: {
   priority: 60000
   ruleCollections: [
    {
      name: 'RuleCollection01'
      priority: 10000
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
   ] 
  }
}

resource RuleGroup02 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-07-01' = {
  name: 'NetworkGroup02'
  parent: firewallPolicy
  dependsOn: [
    RuleGroup01
  ]
  properties: {
   priority: 64000
   ruleCollections: [
    {
      name: 'RuleCollection02'
      priority: 15000
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
   ] 
  }
}

resource RuleGroup03 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-01-01' = {
  name: 'NatGroup03'
  parent: firewallPolicy
  dependsOn: [
    RuleGroup02
  ]
  properties: {
   priority: 62000
   ruleCollections: [
    {
      name: 'RuleCollection03'
      ruleCollectionType:  'FirewallPolicyNatRuleCollection'
      action: {
        type: 'DNAT'
      }
      priority: 2000
      rules: [
        {
          name: 'AllowHttp'
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
           pip.properties.ipAddress
          ]
          translatedAddress: '10.10.4.11'
          translatedPort: '80'
        }
      ]
    }
   ] 
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'pip-afw-${affix}-01'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}


output publicip string = pip.properties.ipAddress
