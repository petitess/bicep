targetScope = 'subscription'

param tags object
param env string
param location string = deployment().location
param storageAccounts ({
  name: string
  resourceGroup: string?
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
var prefix = toLower('ollama-${env}')
var stOutputs = toObject(
  stM,
  entry => entry.outputs.name,
  entry =>
    ({
      name: entry.outputs.name
      id: entry.outputs.id
      key1: entry.outputs.key1
      connectionStr: entry.outputs.defaultEndpointsProtocol
    })
)
func name(res string, instance string) string => '${res}-${prefix}-${instance}'

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg', '01')
  location: location
  tags: tags
}

module stM 'st.bicep' = [
  for (st, i) in storageAccounts: {
    name: st.name
    scope: resourceGroup(st.?resourceGroup ?? name('rg', '01'))
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
        'no-vnet',
        //vnetM.outputs.name,
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

module cae 'cae.bicep' = {
  name: 'cae_deployment'
  scope: rg
  params: {
    caeName: name('cae', '01')
    stKey: stOutputs.stollamadev01.key1
  }
}

module ca_gui 'ca_gui.bicep' = {
  name: 'ca_gui_deployment'
  scope: rg
  params: {
    caName: name('ca-gui', '01')
    envId: cae.outputs.caeId
    apiUrl: ca_api.outputs.caUrl
  }
}

module ca_api 'ca_api.bicep' = {
  name: 'ca_api_deployment'
  scope: rg
  params: {
    caName: name('ca-api', '01')
    envId: cae.outputs.caeId
  }
}
