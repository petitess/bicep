targetScope = 'subscription'

extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:0.1.8-preview'

param timestamp int = dateTimeToEpoch(utcNow())
param location string
param tags object
param vnet object
param storageAccounts ({
  name: string
  rgName: string?
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
param apps ({
  name: string
  resourceGroup: string
  appServicePlanName: ('asp-infra-prod-01')
  privateEndpoints: ({ sites: string?, 'sites-stage': string? })
  keyVault: ({ allowIPs: string[]?, ipPep: string, customName: string? })?
  appSettings: ({ name: string, value: string })[]?
  healthpath: string?
  alertsEnabled: bool
  customDomain: string?
  virtualApplication: array?
  slot: ({
    name: ('stage')?
    appSettings: ({ name: string, value: string })[]
    customDomain: string?
    authEnabled: bool?
  }?)
  authEnabled: bool
  auth: ({ authClientId: string, authAllowedAudience: string })?
  sqlServer: ({
    dbCount: int
    ipPep: string
    sqlDtu: int
    sqlTier: string
    publicNetworkAccess: 'Disabled' | 'Enabled'
    entraOnlyAuthentication: bool?
  })?
})[]
param kv object
param vm array
param vmAdc array
param webtests array
param vgw object
param maintenanceConfigurations array
@description('az ad sp list  --display-name "microsoft.azure.certificateregistration"')
param appCertificateRegistration string = '5ac1ac3c-9e22-439b-acfb-6694f6522409'
@description('az ad sp show --id "abfa0a7c-a6b6-4736-8310-5855508787cd"')
param appMicrosoftAzureAppService string = '2d0abffa-b360-4f2f-9478-951498a43bd8'
param myIP string = '188.150.104.230'

var affix = toLower('${tags.Application}-${tags.Environment}')
func name(prefix string, instance string) string => '${prefix}-${affix}-${instance}'

var env = toLower(tags.Environment)
var snet = toObject(vnetE.properties.subnets, subnet => subnet.name)
var deployLock = false
var domains = [
  'privatelink.blob.${environment().suffixes.storage}'
  'privatelink.file.${environment().suffixes.storage}'
  'privatelink.queue.${environment().suffixes.storage}'
  'privatelink.table.${environment().suffixes.storage}'
  'privatelink.azurewebsites.net'
  'privatelink.vaultcore.azure.net'
  'privatelink.sdc.backup.windowsazure.com'
  'privatelink.azure-automation.net'
  'privatelink.monitor.azure.com'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.agentsvc.azure-automation.net'
  'privatelink${environment().suffixes.sqlServerHostname}'
]
var auth = {
  authAllowedAudience: appReg.identifierUris[0]
  authClientId: appReg.appId
}

resource vnetE 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: name('vnet', '01')
  scope: resourceGroup(name('rg-vnet', '01'))
  dependsOn: [
    vnetM
    rg
  ]
}

resource rg 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: name('rg-vnet', '01')
  location: location
  tags: tags
}

resource rgMgmt 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: name('rg-management', '01')
  location: location
  tags: tags
}

resource rgDns 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: name('rg-dns', '01')
  location: location
  tags: tags
}

resource rgAppi 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: name('rg-appi', '01')
  location: location
  tags: tags
}

resource rgAsp 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: name('rg-asp', '01')
  location: location
  tags: tags
}

module defender 'modules/defender.bicep' = if (false) {
  name: 'defender'
}

module vnetM 'modules/vnet.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    addressPrefixes: vnet.addressPrefixes
    dnsServers: vnet.dnsServers
    location: location
    name: name('vnet', '01')
    natGateway: vnet.natGateway
    peerings: vnet.peerings
    subnets: vnet.subnets
  }
}

module log 'modules/log.bicep' = {
  name: 'log'
  scope: rgMgmt
  params: {
    name: name('log', '01')
    location: location
    sku: 'PerGB2018'
    retentionInDays: 30
    solutions: [
      'VMInsights'
      'Security'
      'ServiceMap'
      'ChangeTracking'
    ]
    events: [
      'System'
      'Application'
    ]
  }
}

module ag 'modules/ag.bicep' = {
  scope: rgMgmt
  name: 'action-groups'
  params: {
    location: 'global'
  }
}

module alert 'modules/alert.bicep' = {
  scope: rgMgmt
  name: 'alert'
  params: {
    tags: tags
    actionGroupId: ag.outputs.agP5Bas
  }
}

resource rgSt 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: name('rg-st', '01')
  location: location
  tags: tags
}

module st 'modules/st.bicep' = [
  for st in storageAccounts: {
    name: st.name
    scope: resourceGroup(st.?rgName ?? rgSt.name)
    params: {
      name: st.name
      location: location
      skuName: st.skuName
      isSftpEnabled: st.isSftpEnabled
      publicAccess: st.publicAccess
      allowedIPs: st.allowedIPs
      vnetRg: rg.name
      vnetName: vnetM.outputs.name
      dnsRg: rgDns.name
      prodsubid: subscription().subscriptionId
      privateEndpoints: items(st.privateEndpoints)
      shares: st.shares
      containers: st.containers
    }
  }
]
module aa 'modules/aa.bicep' = {
  scope: rgMgmt
  name: 'aa'
  params: {
    location: location
    name: name('aa', '01')
    dnsRg: rgDns.name
    vnetName: vnetM.outputs.name
    vnetRg: rg.name
    privateEndpoints: {
      Webhook: '10.10.3.20'
    }
  }
}

resource rbacAA 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, aa.name, '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  properties: {
    principalId: aa.outputs.principalId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleAssignments',
      '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    )
    principalType: 'ServicePrincipal'
  }
}

module azureMonitor 'modules/azuremonitor.bicep' = {
  scope: rgMgmt
  name: 'monitor-pls'
  params: {
    dnsRg: rgDns.name
    location: location
    snetId: snet['snet-pep'].id
    name: name('pls', '01')
    logId: log.outputs.id
    dceId: data.outputs.dataEndpointId
    appiId: appi.outputs.id
  }
}

module kvM 'modules/kv.bicep' = {
  scope: rgMgmt
  name: 'kv'
  params: {
    name: name('kv-xyz', '01')
    location: location
    tags: tags
    snetPepId: snet['snet-pep'].id
    ipAddress: cidrSubnet(snet['snet-pep'].properties.addressPrefix, 32, 25)
    allowIPs: [
      myIP
    ]
    privateDnsZoneId: resourceId(
      subscription().subscriptionId,
      rgDns.name,
      'Microsoft.Network/privateDnsZones',
      'privatelink.vaultcore.azure.net'
    )
    rbac: [
      {
        principalId: appCertificateRegistration
        role: 'Key Vault Secrets Officer'
      }
      {
        principalId: appMicrosoftAzureAppService
        role: 'Key Vault Secrets Officer'
      }
    ]
  }
}

module rsv 'modules/rsv.bicep' = if (true) {
  scope: rgMgmt
  name: 'rsv'
  params: {
    dnsRgName: rgDns.name
    location: location
    name: name('rsv', '01')
    snetId: snet['snet-pep'].id
    timeZone: 'W. Europe Standard Time'
    retentionTimes: [
      '22:30:00'
    ]
    scheduleRunTimes: [
      '22:30:00'
    ]
    sku: {
      name: 'RS0'
      tier: 'Standard'
    }
  }
}

module bas 'modules/bas.bicep' = if (false) {
  scope: rg
  name: 'bastion'
  params: {
    location: location
    name: name('bas', '01')
    subnet: snet.AzureBastionSubnet.id
    vnetId: vnetM.outputs.id
    sku: 'Basic'
  }
}

module pdnszM 'modules/pdnsz.bicep' = [
  for (domain, i) in domains: {
    name: 'pdnsz-${split(domain, '.')[1]}'
    scope: rgDns
    params: {
      name: domain
      vnetId: vnetM.outputs.id
    }
  }
]

module id 'modules/id.bicep' = {
  scope: rgMgmt
  name: 'id'
  params: {
    location: location
    name: name('id', '01')
  }
}

module asp 'modules/asp.bicep' = {
  scope: rgAsp
  name: 'asp'
  params: {
    env: env
    location: location
    aspList: [
      {
        aspName: name('asp', '01')
        OS: 'Linux'
        skuName: 'P0V3'
      }
    ]
  }
}

resource rbacId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, id.name, '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  properties: {
    principalId: id.outputs.principalId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleAssignments',
      '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    )
    principalType: 'ServicePrincipal'
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2024-07-01' = [
  for vm in filter(vm, v => empty(v.availabilitySetName)): {
    name: toLower('rg-${vm.name}')
    location: location
    tags: union(vm.tags, {
      Application: tags.Application
      Environment: tags.Environment
    })
  }
]

module vmM 'modules/vm.bicep' = [
  for (vm, i) in vm: if (false) {
    scope: resourceGroup(vm.rgName)
    name: vm.name
    params: {
      ag: ag.outputs.agP3Bas
      availabilitySetName: vm.availabilitySetName
      backup: vm.backup
      computerName: vm.?computerName ?? vm.name
      dataDisks: vm.dataDisks
      extensions: vm.extensions
      imageReference: vm.imageReference
      location: location
      log: log.outputs.id
      monitor: vm.monitor
      name: vm.name
      networkInterfaces: vm.networkInterfaces
      osDiskSizeGB: vm.osDiskSizeGB
      plan: vm.plan
      rsvDefaultPolicy: vm.name == 'vmfileprod01'
        ? resourceId(
            subscription().subscriptionId,
            rg.name,
            'Microsoft.RecoveryServices/vaults/backupPolicies',
            name('rsv', '01'),
            'Policy-FileServer01'
          )
        : resourceId(
            subscription().subscriptionId,
            rg.name,
            'Microsoft.RecoveryServices/vaults/backupPolicies',
            name('rsv', '01'),
            'DefaultPolicy'
          )
      rsvName: name('rsv', '01')
      rsvRg: rg.name
      tags: union(tags, vm.tags)
      vmSize: vm.vmSize
      vnetname: vnetM.outputs.name
      vnetrg: rg.name
      DataWinId: data.outputs.DataRuleWinId
      DataLinuxId: data.outputs.DataRuleLinuxId
      dataEndpointId: data.outputs.dataEndpointId
      deployLock: deployLock
      kvId: kvM.outputs.id
      kvName: kvM.outputs.name
      kvRg: rgMgmt.name
      certificateUrl: '${kvM.outputs.kvUrl}${kv.a3careSecret}${kv.a3careVersion}'
      installCompCert: vm.installCompCert
      loadBalancerBackendAddressPoolId: contains(vm, 'loadbalancer')
        ? resourceId(
            subscription().subscriptionId,
            vm.loadbalancer.rgName,
            'Microsoft.Network/loadBalancers/backendAddressPools',
            vm.loadbalancer.name,
            'pool-01'
          )
        : ''
    }
  }
]

module lb 'modules/lb.bicep' = {
  scope: resourceGroup('rg-vmadc${env}01')
  dependsOn: [
    rgAvail
  ]
  name: 'lb'
  params: {
    location: location
    name: name('lb-adc', '01')
    logId: log.outputs.id
  }
}

module lbi 'modules/lbi.bicep' = {
  scope: resourceGroup('rg-vmadc${env}01')
  name: 'lbi'
  params: {
    location: location
    name: name('lbi-adc', '01')
    vnetrg: rg.name
    vnetname: vnetM.outputs.name
  }
}

resource rgAvail 'Microsoft.Resources/resourceGroups@2024-07-01' = [
  for avail in filter(concat(vm, vmAdc), v => !empty(v.availabilitySetName) && contains(v.name, '01')): {
    name: toLower('rg-${avail.name}')
    location: location
    tags: tags
  }
]

module avail 'modules/avail.bicep' = [
  for (avail, i) in filter(concat(vm, vmAdc), v => !empty(v.availabilitySetName) && contains(v.name, '01')): {
    scope: rgAvail[i]
    name: 'avail-${avail.name}'
    params: {
      name: 'avail-${avail.name}'
      location: location
    }
  }
]

module vmAdcM 'modules/vmadc.bicep' = [
  for (vm, i) in vmAdc: if (false) {
    scope: resourceGroup(vm.rgName)
    name: '${vm.name}'
    params: {
      ag: ag.outputs.agP3Bas
      availabilitySetName: vm.availabilitySetName
      dataDisks: vm.dataDisks
      imageReference: vm.imageReference
      location: location
      log: log.outputs.id
      monitor: vm.monitor
      name: vm.name
      networkInterfaces: vm.networkInterfaces
      osDiskSizeGB: vm.osDiskSizeGB
      plan: vm.plan
      tags: union(tags, vm.tags)
      vmSize: vm.vmSize
      vnetname: vnetM.outputs.name
      vnetrg: rg.name
      kvName: kvM.outputs.name
      kvRg: rgMgmt.name
      loadBalancerBackendAddressPoolId: contains(vm.name, '01') || contains(vm.name, '02')
        ? lb.outputs.poolid
        : lb.outputs.poolidX
      IloadBalancerBackendAddressPoolId: contains(vm.name, '01') || contains(vm.name, '02')
        ? lbi.outputs.poolid
        : lbi.outputs.poolidX
      deployLock: deployLock
    }
  }
]

module vgwM 'modules/vgw.bicep' = if (false) {
  scope: rg
  name: 'vgw'
  params: {
    location: location
    vnetName: name('vnet', '01')
    name: name('vgw', '01')
    vgw: vgw
  }
}

module lgw 'modules/vgw-lgw.bicep' = [
  for vpn in vgw.customers: if (false) {
    scope: rg
    name: 'lgw-${vpn.name}'
    params: {
      gatewayIpAddress: vpn.gatewayIpAddress
      ipsecPolicies: vpn.?ipsecPolicies ?? []
      localAddresses: vpn.localAddresses
      name: vpn.name
      location: location
      tag: vpn.tag
      vgwId: vgwM.outputs.id
      kvName: kvM.outputs.name
      kvRg: rgMgmt.name
    }
  }
]

module data 'modules/data.bicep' = {
  scope: rgMgmt
  name: 'datarules'
  params: {
    location: location
    env: env
    workspaceResourceId: log.outputs.id
  }
}

module mc 'modules/mc.bicep' = [
  for mc in maintenanceConfigurations: {
    scope: rgMgmt
    name: mc.name
    params: {
      name: mc.name
      location: location
      detectionTags: mc.detectionTags
      recurEvery: mc.recurEvery
      startDateTime: mc.startDateTime
    }
  }
]

module appi 'modules/appi.bicep' = {
  scope: rgAppi
  name: 'appi'
  params: {
    name: name('appi', '01')
    location: location
    WorkspaceResourceId: log.outputs.id
    webtests: webtests
    actionGroupId: ag.outputs.agP3Bas
  }
}

resource rgApp 'Microsoft.Resources/resourceGroups@2024-07-01' = [
  for rg in union(map(apps, rg => rg.resourceGroup), map(apps, rg => rg.resourceGroup)): {
    name: toLower(rg)
    location: location
    tags: tags
  }
]

module App 'modules/app.bicep' = [
  for (app, i) in apps: {
    scope: resourceGroup(app.resourceGroup)
    name: toLower(app.name)
    params: {
      name: toLower(app.name)
      aspId: resourceId(subscription().subscriptionId, rgAsp.name, 'Microsoft.Web/serverfarms', app.appServicePlanName)
      location: location
      snetOutboundId: snet['snet-asp'].id
      snetPepId: snet['snet-pep'].id
      LogId: log.outputs.id
      thumbprint: '' //asp.outputs.thumbprint01
      dnsRg: rgDns.name
      healthpath: app.?healthpath
      actionGroupId: ag.outputs.agP5Bas
      alertsEnabled: app.?alertsEnabled
      privateEndpoints: app.privateEndpoints
      keyVault: app.?keyVault
      appSettings: app.?appSettings
      slot: app.?slot
      customDomain: app.?customDomain
      virtualApplication: app.?virtualApplication
      auth: app.authEnabled ? auth : {}
    }
  }
]

module SQLApp 'modules/sql.bicep' = [
  for (s, i) in apps: if (!empty(s.?sqlServer ?? {})) {
    scope: resourceGroup(s.resourceGroup)
    name: 'sql-${s.name}'
    params: {
      appName: s.name
      location: location
      LogId: log.outputs.id
      entraGroupName: appGrp[i].displayName
      entraGroupSid: appGrp[i].id
      dbCount: s.sqlServer.?dbCount
      snetPepId: snet['snet-pep'].id
      ipPep: s.sqlServer.?ipPep
      dnsRg: rgDns.name
      sqlDtu: s.sqlServer.?sqlDtu
      sqlTier: s.sqlServer.?sqlTier
      entraOnlyAuthentication: s.sqlServer.?entraOnlyAuthentication
      publicNetworkAccess: s.sqlServer.?publicNetworkAccess
    }
  }
]

output aa array = [for i in apps: { Name: i.name, name2: substring(i.name, 0, length(i.name) - 1), name3: substring(i.name, 0, length(i.name) - 2) }]

resource appGrp 'Microsoft.Graph/groups@v1.0' = [
  for g in apps: {
    displayName: 'grp-sql-${g.name}'
    mailEnabled: false
    mailNickname: 'grp-sql-${g.name}'
    securityEnabled: true
    uniqueName: 'grp-sql-${g.name}'
  }
]

resource appReg 'Microsoft.Graph/applications@v1.0' = {
  displayName: 'app-func-${env}-01'
  uniqueName: 'app-func-${env}-01'
  description: 'Updated: ${dateTimeFromEpoch(timestamp)}'
  identifierUris: [
    'api://func-${env}-01'
  ]
}

module policy1 'policies/kv-unallow-all-networks.bicep' = {
  name: 'p-kv1'
  params: {
    idId: id.outputs.id
    location: location
  }
}

module policy2 'policies/res-require-resource-lock.bicep' = {
  name: 'p-res1'
  params: {
    idId: id.outputs.id
    location: location
  }
}

module policy3 'policies/st-unallow-cors-any-blob.bicep' = {
  name: 'p-st1'
  params: {
    idId: id.outputs.id
    location: location
  }
}
