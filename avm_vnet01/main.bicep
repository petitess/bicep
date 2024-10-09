targetScope = 'subscription'

param config object
param environment string
param location string = deployment().location
param addressPrefixes array
param subnets array

var prefix = toLower('${config.product}-sys-${environment}-${config.location}')
var prefixSt = toLower('${config.product}-st-${environment}-${config.location}')

var subnet = toObject(
  reference(
    resourceId(subscription().subscriptionId, rg.name, 'Microsoft.Network/virtualNetworks', 'vnet-${prefix}-01'),
    '2023-11-01'
  ).subnets,
  subnet => subnet.name
)

var subnetsAndNsg = [
  for snet in subnets: union(
    snet,
    snet.name != 'GatewaySubnet'
      ? {
          networkSecurityGroupResourceId: resourceId(
            subscription().subscriptionId,
            rg.name,
            'Microsoft.Network/networkSecurityGroups',
            'nsg-${snet.name}'
          )
        }
      : {}
  )
]

var domains = [
  'privatelink.vaultcore.azure.net'
  'privatelink.blob.${az.environment().suffixes.storage}'
  'privatelink.file.${az.environment().suffixes.storage}'
  'privatelink.azurewebsites.net'
]

// var storageExists = true
var myIp = '188.150.11.11'

func pdnszId(rgName string, pdnsz string) string =>
  resourceId(subscription().subscriptionId, rgName, 'Microsoft.Network/privateDnsZones', pdnsz)

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefix}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

resource rgSt 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefixSt}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

module id 'br:mcr.microsoft.com/bicep/avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  scope: rg
  name: 'id'
  params: {
    name: 'id-${prefix}-01'
  }
}

module nsgM 'br:mcr.microsoft.com/bicep/avm/res/network/network-security-group:0.5.0' = [
  for nsg in subnets: if (nsg.name != 'GatewaySubnet') {
    name: 'nsg-${nsg.name}'
    scope: rg
    params: {
      name: 'nsg-${nsg.name}'
      securityRules: nsg.securityRules
    }
  }
]

module logM 'br:mcr.microsoft.com/bicep/avm/res/operational-insights/workspace:0.7.0' = {
  scope: rg
  name: 'log'
  params: {
    name: 'log-${prefix}-01'
    skuName: 'PerGB2018'
  }
}

module appiM 'br:mcr.microsoft.com/bicep/avm/res/insights/component:0.4.1' = {
  scope: rg
  name: 'appi'
  params: {
    name: 'appi-${prefix}-01'
    workspaceResourceId: logM.outputs.resourceId
  }
}

module vnetM 'br:mcr.microsoft.com/bicep/avm/res/network/virtual-network:0.4.0' = {
  scope: rg
  name: 'vnet'
  params: {
    addressPrefixes: addressPrefixes
    name: 'vnet-${prefix}-01'
    subnets: subnetsAndNsg
    // roleAssignments: [
    //   {
    //     principalId: id.outputs.principalId
    //     roleDefinitionIdOrName: 'Network Contributor'
    //   }
    // ]
  }
}

module pdnszM 'br:mcr.microsoft.com/bicep/avm/res/network/private-dns-zone:0.6.0' = [
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

module stFuncM 'br:mcr.microsoft.com/bicep/avm/res/storage/storage-account:0.9.1' = {
  scope: rgSt
  name: 'st'
  params: {
    name: toLower('st${config.product}${environment}${config.location}01')
    allowSharedKeyAccess: true
    kind: 'StorageV2'
    publicNetworkAccess: 'Enabled'
    defaultToOAuthAuthentication: true
    skuName: 'Standard_LRS'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        {
          value: myIp
        }
      ]
    }
    blobServices: {
      containerDeleteRetentionPolicyEnabled: false
      containerDeleteRetentionPolicyDays: 7
      deleteRetentionPolicyEnabled: false
      deleteRetentionPolicyDays: 6
      containers: [
        {
          name: 'container01'
          immutableStorageWithVersioningEnabled: false
        }
      ]
    }
    fileServices: {
      shares: [
        {
          name: 'func01'
        }
      ]
    }
    privateEndpoints: [
      {
        service: 'file'
        subnetResourceId: subnet['snet-pep'].id
        name: toLower('pep-st${config.product}func${environment}${config.location}01-file')
        customNetworkInterfaceName: toLower('nic-st${config.product}func${environment}${config.location}01-file')
        privateDnsZoneResourceIds: [
          pdnszId(rg.name, 'privatelink.file.${az.environment().suffixes.storage}')
        ]
      }
      {
        service: 'blob'
        subnetResourceId: subnet['snet-pep'].id
        name: toLower('pep-st${config.product}func${environment}${config.location}01-blob')
        customNetworkInterfaceName: toLower('nic-st${config.product}func${environment}${config.location}01-blob')
        privateDnsZoneResourceIds: [
          pdnszId(rg.name, 'privatelink.blob.${az.environment().suffixes.storage}')
        ]
      }
    ]
    roleAssignments: [
      {
        principalId: id.outputs.principalId
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
      }
    ]
  }
}
