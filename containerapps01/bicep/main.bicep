targetScope = 'subscription'

param environment string
param location string
param config object
param addressPrefixes array
param subnets array

var prefix = toLower('${config.product}-sys-${environment}-${config.location}')
var repoDeployed = true
var VmssObjectId = ''

var subnetsAndNsg = [
  for snet in subnets: union(snet, {
    networkSecurityGroupResourceId: resourceId(
      subscription().subscriptionId,
      rg.name,
      'Microsoft.Network/networkSecurityGroups',
      'nsg-${snet.name}'
    )
  })
]

var domains = [
  'privatelink.azurecr.io'
]

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-infra-${environment}-01'
  tags: config.tags
  location: location
}

resource rgAcr 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-acr-${environment}-01'
  tags: config.tags
  location: location
}

resource rgCa 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-ca-${environment}-01'
  tags: config.tags
  location: location
}

module rbacM 'modules/rbac.bicep' = if (!empty(VmssObjectId)) {
  scope: rgAcr
  name: 'rbac-acr'
  params: {
    principalId: !empty(VmssObjectId) ? VmssObjectId : ''
    roles: [
      'AcrPush'
    ]
  }
}

module nsgM 'br:mcr.microsoft.com/bicep/avm/res/network/network-security-group:0.2.0' = [
  for nsg in subnets: {
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
    addressPrefixes: addressPrefixes
    name: 'vnet-${prefix}-01'
    subnets: subnetsAndNsg
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

module acrM 'modules/acr.bicep' = {
  scope: rgAcr
  name: 'acr'
  params: {
    name: 'acr${config.product}sys${environment}${config.location}01'
    snetPepId: resourceId(
      subscription().subscriptionId,
      rg.name,
      'Microsoft.Network/virtualNetworks/subnets',
      vnetM.outputs.name,
      'snet-pep'
    )
    rgDns: rg.name
  }
}

module caeM 'modules/cae.bicep' = {
  scope: rgCa
  name: 'cae'
  params: {
    name: 'cae-${prefix}-01'
    snetId: resourceId(
      subscription().subscriptionId,
      rg.name,
      'Microsoft.Network/virtualNetworks/subnets',
      vnetM.outputs.name,
      'snet-cae-outbound'
    )
  }
}

module ca 'modules/ca.bicep' = if (repoDeployed) {
  scope: rgCa
  name: 'ca01'
  params: {
    name: 'ca-${prefix}-01'
    acrName: acrM.outputs.name
    acrRepo: 'c-sharp-web'
    acrRepoVer: '114240'
    caeId: caeM.outputs.id
    acrAccessKey: acrM.outputs.key
  }
}
