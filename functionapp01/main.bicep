targetScope = 'subscription'

param tags object
param env string
param location string = deployment().location
param vnet object
param funcApps ({
  name: string
  resourceGroup: string
  kind: 'functionapp,linux' | 'functionapp'
  aspName: string?
  appSettings: ({ name: string, value: string })[]?
  slot: ({
    name: ('stage')?
    appSettings: ({ name: string, value: string })[]
    customDomain: string?
    authEnabled: bool?
  }?)
  privateEndpoints: ({ sites: string?, 'sites-stage': string? })
  customDomain: string?
  rbac: ({
    role: ('Website Contributor' | 'Reader' | 'Contributor' | 'Storage Blob Data Contributor')
    principalId: string
  })[]?
  authEnabled: bool
  auth: ({ authClientId: string, authAllowedAudience: string })?
  isFlexConsumptionTier: bool
  storageName: string?
  storageContainerName: string?
  runtimeName: resourceInput<'Microsoft.Web/sites@2025-03-01'>.properties.functionAppConfig.runtime.name?
  runtimeVersion: resourceInput<'Microsoft.Web/sites@2025-03-01'>.properties.functionAppConfig.runtime.version?
})[]
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
var snet = toObject(vnetE.properties.subnets, subnet => subnet.name)
var domains = [
  'privatelink.blob.${environment().suffixes.storage}'
  'privatelink.file.${environment().suffixes.storage}'
  'privatelink.azurewebsites.net'
  'privatelink.cognitiveservices.azure.com'
  'privatelink.openai.azure.com'
  'privatelink.services.ai.azure.com'
]
func name(res string, instance string) string => '${res}-${prefix}-${instance}'
func aspId(aspName string?, rgName string) string =>
  resourceId(subscription().subscriptionId, rgName, 'Microsoft.Web/serverfarms', aspName)

resource vnetE 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  name: name('vnet', '01')
  scope: resourceGroup(name('rg-vnet', '01'))
  dependsOn: [
    vnetM
    rg
  ]
}

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-vnet', '01')
  location: location
  tags: tags
}

resource rgSb 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-integration-${env}-01'
  location: location
  tags: tags
}

resource rgAsp 'Microsoft.Resources/resourceGroups@2025-04-01' = if (false) {
  location: location
  tags: tags
  name: name('rg-asp', '01')
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

module st 'st.bicep' = [
  for (st, i) in storageAccounts: {
    name: '${st.name}-${i}'
    scope: resourceGroup(st.resourceGroup)
    dependsOn: [
      resourceGroup(rgFunc[i].name)
    ]
    params: {
      name: st.name
      location: location
      skuName: st.skuName
      isSftpEnabled: st.isSftpEnabled
      publicAccess: st.publicAccess
      allowedIPs: st.allowedIPs
      snetPepId: snet['snet-pep'].id
      privateEndpoints: items(st.privateEndpoints)
      privateDnsZoneRg: rg.name
      shares: st.shares
      containers: st.containers
      rbac: st.?rbac ?? []
    }
  }
]

module monitor 'monitor.bicep' = {
  name: 'monitor'
  scope: rg
  params: {
    name: name('monitor', '01')
    location: location
  }
}

module aspFuncFlex 'asp.bicep' = [
  for f in funcApps: if (f.isFlexConsumptionTier) {
    scope: resourceGroup(f.resourceGroup)
    name: 'asp-${f.name}'
    dependsOn: [
      rgFunc
    ]
    params: {
      kind: 'linux'
      name: 'asp-${f.name}'
      sku: 'FC1'
    }
  }
]

module aspLinuxM 'asp.bicep' = if (false) {
  scope: rgAsp
  name: 'asp-linux'
  params: {
    kind: 'linux'
    name: name('asp', '01')
    sku: 'FC1'
  }
}

resource rgFunc 'Microsoft.Resources/resourceGroups@2025-04-01' = [
  for rg in union(map(funcApps, rg => rg.resourceGroup), map(funcApps, rg => rg.resourceGroup)): {
    name: toLower(rg)
    location: location
    tags: tags
  }
]

module funcM 'func.bicep' = [
  for (f, i) in funcApps: {
    scope: resourceGroup(f.resourceGroup)
    name: f.name
    dependsOn: f.isFlexConsumptionTier
      ? [aspFuncFlex[i]]
      : [
          aspLinuxM
        ]
    params: {
      funcAppServicePlanId: f.isFlexConsumptionTier
        ? aspId('asp-${f.name}', f.resourceGroup)
        : aspId(f.aspName, name('asp', '01'))
      name: f.name
      kind: f.kind
      snetOutboundId: f.isFlexConsumptionTier ? snet['snet-app-flex'].id : snet['snet-app'].id
      defaultEndpointsProtocol: st[0].outputs.defaultEndpointsProtocol
      snetPepId: snet['snet-pep'].id
      privateDnsZoneId: resourceId(
        subscription().subscriptionId,
        rg.name,
        'Microsoft.Network/privateDnsZones',
        'privatelink.azurewebsites.net'
      )
      privateEndpoints: f.privateEndpoints
      appSettings: concat(f.?appSettings, [
        {
          name: 'AZURE_OPENAI_API_KEY'
          value: aifM.outputs.key1
        }
        {
          name: 'AZURE_SUBSCRIPTION_ID'
          value: subscription().subscriptionId
        }
      ]) ?? []
      slot: f.?slot ?? {}
      customDomain: f.?customDomain ?? ''
      rbac: f.?rbac ?? []
      auth: f.authEnabled ? {} : {}
      isFlexConsumptionTier: f.isFlexConsumptionTier
      storageName: f.?storageName ?? ''
      storageContainerName: f.?storageContainerName ?? ''
      appiConnectionString: monitor.outputs.ConnectionString
      runtimeName: f.?runtimeName ?? 'dotnet-isolated'
      runtimeVersion: f.?runtimeVersion ?? '8.0'
    }
  }
]

resource rgAif 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-aif', '01')
  location: location
  tags: tags
}

module aifM 'aif.bicep' = {
  scope: rgAif
  params: {
    name: name('aif', '01')
    location: location
    dnsRg: rg.name
    ipAddress1: '10.10.1.73'
    ipAddress2: '10.10.1.74'
    ipAddress3: '10.10.1.75'
    snetPep: snet['snet-pep'].id
    stId: st[0].outputs.id
  }
}

resource rbacMonitor 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (f, i) in funcApps: {
    name: guid(f.name)
    properties: {
      principalId: funcM[i].outputs.principalId
      roleDefinitionId: subscriptionResourceId(
        'Microsoft.Authorization/roleAssignments',
        '3913510d-42f4-4e42-8a64-420c390055eb'
      )
      principalType: 'ServicePrincipal'
    }
  }
]
