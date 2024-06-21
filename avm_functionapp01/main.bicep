targetScope = 'subscription'

param config object
param environment string
param location string = deployment().location
param addressPrefixes object
param subnets object

var prefix = toLower('${config.product}-sys-${environment}-${config.location}')
var prefixFunc = toLower('${config.product}-func-${environment}-${config.location}')

var roles = {
  'Network Contributor': '4d97b98b-1d4f-4787-a291-c67834d212e7'
  'Key Vault Admin': '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  'Automation Contributor': 'f353d9bd-d4a6-484e-a77a-8050b599b867'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  'Storage File Data Privileged Contributor': '69566ab7-960f-475b-8e7c-b3118f30c6bd'
  'Storage Blob Data Contributor': 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

var subnet = toObject(
  reference(
    resourceId(subscription().subscriptionId, rg.name, 'Microsoft.Network/virtualNetworks', 'vnet-${prefix}-01'),
    '2023-11-01'
  ).subnets,
  subnet => subnet.name
)

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
  'privatelink.file.${az.environment().suffixes.storage}'
  'privatelink.azurewebsites.net'
]

var storageExists = false
var myIp = '188.150.1.1'

func pdnszId(rgName string, pdnsz string) string =>
  resourceId(subscription().subscriptionId, rgName, 'Microsoft.Network/privateDnsZones', pdnsz)

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefix}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

resource rgFunc 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefixFunc}-01'
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

module aspM 'br:mcr.microsoft.com/bicep/avm/res/web/serverfarm:0.2.2' = {
  scope: rgFunc
  name: 'asp'
  params: {
    name: 'asp-${prefixFunc}-01'
    skuCapacity: 1
    skuName: 'P0v3'
    kind: 'Linux'
    zoneRedundant: false
  }
}

module stFuncM 'br:mcr.microsoft.com/bicep/avm/res/storage/storage-account:0.9.1' = {
  scope: rgFunc
  name: 'st-func'
  params: {
    name: toLower('st${config.product}func${environment}${config.location}01')
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
  }
}

resource stFuncE 'Microsoft.Storage/storageAccounts@2023-05-01' existing = if (storageExists) {
  name: toLower('st${config.product}func${environment}${config.location}01')
  scope: rgFunc
}

var funcAppSettings = [
  // {
  //   name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
  //   value: appiConnectionString
  // }
  {
    name: 'AzureWebJobsDashboard'
    value: storageExists
      ? 'DefaultEndpointsProtocol=https;AccountName=${stFuncM.outputs.name};AccountKey=${stFuncE.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
      : ''
  }
  {
    name: 'AzureWebJobsStorage'
    value: storageExists
      ? 'DefaultEndpointsProtocol=https;AccountName=${stFuncM.outputs.name};AccountKey=${stFuncE.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
      : ''
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: 'dotnet-isolated'
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: storageExists
      ? 'DefaultEndpointsProtocol=https;AccountName=${stFuncM.outputs.name};AccountKey=${stFuncE.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
      : ''
  }
  {
    name: 'WEBSITE_CONTENTOVERVNET'
    value: '1'
  }

  {
    name: 'WEBSITE_CONTENTSHARE'
    value: 'func01'
  }
  {
    name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
    value: '1'
  }
  {
    name: 'WEBSITE_RUN_FROM_PACKAGE'
    value: '1'
  }
]

module funcM 'br:mcr.microsoft.com/bicep/avm/res/web/site:0.3.8' = {
  scope: rgFunc
  name: 'func-linux'
  params: {
    kind: 'functionapp,linux'
    name: 'func-${prefixFunc}-01'
    serverFarmResourceId: aspM.outputs.resourceId
    virtualNetworkSubnetId: subnet['snet-app-outbound'].id
    publicNetworkAccess: 'Enabled'
    storageAccountResourceId: stFuncM.outputs.resourceId
    storageAccountRequired: false
    vnetRouteAllEnabled: false
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v8.0'
      http20Enabled: false
      appSettings: funcAppSettings
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
    }
    managedIdentities: {
      systemAssigned: true
    }
    privateEndpoints: [
      {
        subnetResourceId: subnet['snet-pep'].id
        name: 'pep-func-${prefixFunc}-01'
        customNetworkInterfaceName: 'nic-func-${prefixFunc}-01'
        privateDnsZoneResourceIds: [
          pdnszId(rg.name, 'privatelink.azurewebsites.net')
        ]
      }
    ]
  }
}

module rbacFuncBlob 'br:mcr.microsoft.com/bicep/avm/ptn/authorization/resource-role-assignment:0.1.0' = {
  scope: rgFunc
  name: 'rbac-func-blob'
  params: {
    principalId: funcM.outputs.systemAssignedMIPrincipalId
    resourceId: stFuncM.outputs.resourceId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roles['Storage Blob Data Contributor'])
  }
}

module rbacFuncFile 'br:mcr.microsoft.com/bicep/avm/ptn/authorization/resource-role-assignment:0.1.0' = {
  scope: rgFunc
  name: 'rbac-func-file'
  params: {
    principalId: funcM.outputs.systemAssignedMIPrincipalId
    resourceId: stFuncM.outputs.resourceId
    roleDefinitionId: resourceId(
      'Microsoft.Authorization/roleDefinitions',
      roles['Storage File Data Privileged Contributor']
    )
  }
}

resource rbacFuncReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('func-reader')
  properties: {
    principalId: funcM.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roles.Reader)
  }
}
