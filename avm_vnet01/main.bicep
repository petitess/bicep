targetScope = 'subscription'

param config object
param environment string
param location string = deployment().location
param addressPrefixes object
param subnets object

var prefix = toLower('${config.product}-sys-${environment}-${config.location}')

var subnetsAndNsg = [
  for snet in subnets[environment]: union(snet, {
    networkSecurityGroupResourceId: resourceId(
      subscription().subscriptionId,
      rg.name,
      'Microsoft.Network/networkSecurityGroups',
      'nsg-${snet.name}'
    )
  })
]

var domains = [
  'privatelink.vaultcore.azure.net'
  'privatelink.blob.${az.environment().suffixes.storage}'
]

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefix}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

module id 'br:mcr.microsoft.com/bicep/avm/res/managed-identity/user-assigned-identity:0.2.1' = {
  scope: rg
  name: 'id'
  params: {
    name: 'id-${prefix}-01'
  }
}

module nsgM 'br:mcr.microsoft.com/bicep/avm/res/network/network-security-group:0.2.0' = [
  for nsg in subnets[environment]: {
    name: 'nsg-${nsg.name}'
    scope: rg
    params: {
      name: 'nsg-${nsg.name}'
      securityRules: nsg.securityRules
    }
  }
]

module vnetM 'br:mcr.microsoft.com/bicep/avm/res/network/virtual-network:0.1.6' = {
  scope: rg
  name: 'vnet'
  params: {
    addressPrefixes: addressPrefixes[environment]
    name: 'vnet-${prefix}-01'
    subnets: subnetsAndNsg
    roleAssignments: [
      {
        principalId: id.outputs.principalId
        roleDefinitionIdOrName: 'Network Contributor'
      }
    ]
  }
}

module pdnszM 'br:mcr.microsoft.com/bicep/avm/res/network/private-dns-zone:0.3.0' = [
  for dns in domains: {
    scope: rg
    name: dns
    params: {
      name: dns
      virtualNetworkLinks: [
        {
          virtualNetworkResourceId: vnetM.outputs.resourceId
          registrationEnabled: false
        }
      ]
    }
  }
]
