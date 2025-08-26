targetScope = 'subscription'

param tags object
param env string
param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location
param vnet object
param storageAccounts ({
  name: string
  resourceGroup: string
  skuName: (
    | 'Premium_LRS'
    | 'Premium_ZRS'
    | 'Standard_GRS'
    | 'Standard_GZRS'
    | 'Standard_LRS'
    | 'Standard_RAGRS'
    | 'Standard_RAGZRS'
    | 'Standard_ZRS')
  isSftpEnabled: bool
  publicAccess: ('Disabled' | 'Enabled')
  allowedIPs: array
  privateEndpoints: ({ blob: string?, file: string?, table: string?, queue: string?, web: string?, dfs: string? })
  shares: array
  containers: array
  rbac: ({
    role: (
      | 'Storage Queue Data Contributor'
      | 'Storage Table Data Contributor'
      | 'Storage Blob Data Contributor'
      | 'Storage File Data Privileged Contributor')
    principalId: string
  })[]?
})[]

var unique = take(uniqueString(subscription().subscriptionId), 3)
var prefix = toLower('${unique}-${env}')
var domains = [
  'privatelink.blob.${environment().suffixes.storage}'
  'privatelink.openai.azure.com'
  'privatelink.cognitiveservices.azure.com'
]
func name(res string, instance string) string => '${res}-${prefix}-${instance}'

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-vnet', '01')
  location: location
  tags: tags
}

resource rgAi 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-oai-${prefix}-01'
  location: location
}

resource rgTrsl 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-trsl', '01')
  location: location
  tags: tags
}

module vnetM 'vnet.bicep' = {
  scope: rg
  params: {
    addressPrefixes: vnet.addressPrefixes
    name: name('vnet', '01')
    location: location
    subnets: vnet.subnets
    dnsServers: []
  }
}

module pdnszM 'pdnsz.bicep' = [
  for (domain, i) in domains: {
    name: 'pdnsz-${split(domain, '.')[1]}'
    scope: rg
    params: {
      name: domain
      vnetName: vnetM.outputs.name
      vnetId: vnetM.outputs.id
    }
  }
]

module oaiM 'oai.bicep' = {
  scope: rgAi
  params: {
    name: name('oai', '01')
    snetId: resourceId(
      subscription().subscriptionId,
      rg.name,
      'Microsoft.Network/virtualNetworks/subnets',
      vnetM.outputs.name,
      'snet-pep'
    )
    pdnszId: resourceId(
      subscription().subscriptionId,
      rg.name,
      'Microsoft.Network/privateDnsZones',
      'privatelink.openai.azure.com'
    )
  }
}

module st 'st.bicep' = [
  for (st, i) in storageAccounts: {
    name: '${st.name}-${timestamp}'
    scope: resourceGroup(st.resourceGroup)
    params: {
      name: st.name
      location: location
      skuName: st.skuName
      isSftpEnabled: st.isSftpEnabled
      publicAccess: st.publicAccess
      allowedIPs: st.allowedIPs
      snetPepId: resourceId(
        subscription().subscriptionId,
        rg.name,
        'Microsoft.Network/virtualNetworks/subnets',
        vnetM.outputs.name,
        'snet-pep'
      )
      privateEndpoints: items(st.privateEndpoints)
      privateDnsZoneRg: rg.name
      shares: st.shares
      containers: st.containers
      rbac: st.?rbac ?? []
    }
  }
]

module trslM 'trsl.bicep' = {
  scope: rgTrsl
  params: {
    name: name('trsl', '01')
    snetId: resourceId(
      subscription().subscriptionId,
      rg.name,
      'Microsoft.Network/virtualNetworks/subnets',
      vnetM.outputs.name,
      'snet-pep'
    )
    pdnszId: resourceId(
      subscription().subscriptionId,
      rg.name,
      'Microsoft.Network/privateDnsZones',
      'privatelink.cognitiveservices.azure.com'
    )
    rbac: [
      'Storage Blob Data Contributor'
    ]
  }
}

module aviM 'avi.bicep' = {
  scope: rgAi
  params: {
    name: 'avi-${prefix}-01'
    stId: st[1].outputs.id
    oaiId: oaiM.outputs.id
    rbac: [
      'Storage Blob Data Contributor'
      'Cognitive Services Contributor'
      'Cognitive Services User'
    ]
  }
}
