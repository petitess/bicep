targetScope = 'subscription'

param env string
param location string
param tags object
param vnet object
param timestamp int = dateTimeToEpoch(utcNow())
param storageAccounts ({
  name: string
  rgName: string
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
})[]

var domains = [
  'privatelink.blob.${az.environment().suffixes.storage}'
  'privatelink.file.${az.environment().suffixes.storage}'
]

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  location: location
  tags: tags
  name: 'rg-vnet-${env}-01'
}

resource rgSt 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  location: location
  tags: tags
  name: 'rg-st-${env}-01'
}

resource rgDns 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  location: location
  tags: tags
  name: 'rg-dns-${env}-01'
}

module vnetM 'vnet.bicep' = {
  scope: rg
  name: 'vnet-${timestamp}'
  params: {
    addressPrefixes: vnet.addressPrefixes
    env: env
    location: location
    subnets: vnet.subnets
  }
}

module st 'st.bicep' = [
  for st in storageAccounts: {
    name: '${st.name}-${timestamp}'
    scope: resourceGroup(st.rgName)
    params: {
      name: st.name
      location: location
      skuName: st.skuName
      isSftpEnabled: st.isSftpEnabled
      publicAccess: st.publicAccess
      allowedIPs: st.allowedIPs
      env: env
      prodsubid: subscription().subscriptionId
      privateEndpoints: items(st.privateEndpoints)
      shares: st.shares
      containers: st.containers
    }
  }
]

module pdnszM 'pdnsz.bicep' = [
  for (domain, i) in domains: {
    name: 'pdnsz_${split(domain, '.')[1]}'
    scope: rgDns
    params: {
      name: domain
      vnetName: vnetM.outputs.name
      vnetId: vnetM.outputs.id
    }
  }
]
