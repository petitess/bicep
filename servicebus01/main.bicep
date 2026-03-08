targetScope = 'subscription'

param tags object
param env string
param location string = deployment().location
param vnet object
param serviceBus {
  name: string
  resourcegroup: string
  sku: ('Basic' | 'Standard' | 'Premium')
  topics: {
    name: string
    properties: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2025-05-01-preview'>.properties
    subscriptions: {
      name: string
      properties: resourceInput<'Microsoft.ServiceBus/namespaces/topics/subscriptions@2025-05-01-preview'>.properties
      rules: resourceInput<'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2025-05-01-preview'>.properties[]
    }[]
  }[]
  ipAddress: string
  queues: string[]
  allowIPs: string[]
  rbac: {
    role: ('Azure Service Bus Data Owner' | 'Contributor')
    principalId: string
    principalType: ('Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User')?
  }[]?
}[]

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
  'privatelink.servicebus.windows.net'
  'privatelink.blob.${environment().suffixes.storage}'
  'privatelink.file.${environment().suffixes.storage}'
  'privatelink.azurewebsites.net'
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

resource rgAsp 'Microsoft.Resources/resourceGroups@2025-04-01' = {
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

module sb 'sb.bicep' = [
  for sb in serviceBus: {
    scope: resourceGroup(sb.resourcegroup)
    params: {
      location: location
      name: sb.name
      sku: sb.sku
      topics: sb.topics
      rbac: [
        {
          principalId: deployer().objectId
          role: 'Azure Service Bus Data Owner'
          principalType: 'ServicePrincipal'
        }
      ]
      dnsRg: rg.name
      logId: monitor.outputs.logId
      queues: sb.queues
      ipAddress: sb.ipAddress
      allowIPs: sb.allowIPs
      snetPepId: resourceId(
        subscription().subscriptionId,
        rg.name,
        'Microsoft.Network/virtualNetworks/subnets',
        vnetM.outputs.name,
        'snet-pep'
      )
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

module funcLinux 'func.bicep' = [
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
      appSettings: f.?appSettings ?? []
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
