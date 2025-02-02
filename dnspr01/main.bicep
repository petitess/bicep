targetScope = 'subscription'

extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:0.1.8-preview'

param env string
param location string
param tags object
param vnet object
param timestamp int = dateTimeToEpoch(utcNow())
param dnsServerIp string
param vms array
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

var domains = [
  'privatelink.blob.${environment().suffixes.storage}'
  'privatelink.file.${environment().suffixes.storage}'
]

var affix = toLower('${tags.Application}-${env}')
func name(prefix string, instance string) string => '${prefix}-${affix}-${instance}'

var snet = toObject(vnetE.properties.subnets, subnet => subnet.name)

resource vnetE 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: name('vnet', '01')
  scope: resourceGroup(name('rg-vnet', '01'))
  dependsOn: [
    vnetM
    rg
  ]
}

resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  location: location
  tags: tags
  name: name('rg-vnet', '01')
}

resource rgDns 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  location: location
  tags: tags
  name: name('rg-dns', '01')
}

module vnetM 'vnet.bicep' = {
  scope: rg
  name: 'vnet-${timestamp}'
  params: {
    addressPrefixes: vnet.addressPrefixes
    name: name('vnet', '01')
    location: location
    subnets: vnet.subnets
    dnsServers: [
      dnsServerIp
    ]
  }
}

resource rgFunc 'Microsoft.Resources/resourceGroups@2024-11-01' = [
  for rg in union(map(storageAccounts, rg => rg.resourceGroup), map(storageAccounts, rg => rg.resourceGroup)): {
    name: toLower(rg)
    location: location
    tags: tags
  }
]

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
      snetPepId: snet['snet-pep'].id
      privateEndpoints: items(st.privateEndpoints)
      privateDnsZoneRg: rgDns.name
      shares: st.shares
      containers: st.containers
      rbac: st.?rbac ?? []
    }
  }
]

module pdnszM 'pdnsz.bicep' = [
  for (domain, i) in domains: {
    name: 'pdnsz-${split(domain, '.')[1]}'
    scope: rgDns
    params: {
      name: domain
      vnetName: vnetM.outputs.name
      vnetId: vnetM.outputs.id
    }
  }
]

module dnsprM 'dnspr.bicep' = {
  scope: rg
  name: 'dnspr-${timestamp}'
  params: {
    name: name('dnspr', '01')
    vnetId: vnetM.outputs.id
    snetId: snet['snet-dnspr'].id
    inboundIp: dnsServerIp
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2024-11-01' = [for vm in vms: {
  name: toLower('rg-${vm.name}')
  location: location
  tags: tags
}]

module vmM 'vm.bicep' = [for (vm, i) in vms: {
  scope: rgVm[i]
  name: '${vm.name}-${timestamp}'
  params: {
    adminPass: '12345678.abc'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: rgVm[i].location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgVm[i].tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnetM.outputs.name
    vnetrg: rg.name
    AzureMonitorAgent: vm.AzureMonitorAgent
    DataLinuxId: ''//datarules.outputs.DataLinuxId
    DataWinId: ''//datarules.outputs.DataWinId
  }
}]
