targetScope = 'subscription'

param config object
param environment string
param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location
param vnet object

var prefixSpoke = toLower('${config.product}-spoke-${environment}-${config.location}')
var prefixSt = toLower('${config.product}-st-${environment}-${config.location}')
var prefixDns = toLower('${config.product}-dns-${environment}-${config.location}')
var prefix = toLower('${config.product}-${environment}-${config.location}')
var prefixMonitor = toLower('${config.product}-monitor-${environment}-we')
var snet = toObject(vnetM.outputs.subnets, subnet => subnet.name)
var avdPrincipal = '4913ec4e-67ff-46ee-846c-2c793b399c66' //Enterprise application: Azure Virtual Desktop
var avdLocation = 'WestEurope'
var avdCount = {
  dev: 0
  stg: 0
  prod: 0
}
var allowedSubnets = {
  dev: {
    monitor: '10.100.25.64/27'
    sales: '10.100.22.0/27'
    sven: '10.100.52.0/27'
    avd: '10.100.55.0/24'
  }
  stg: {
    monitor: '10.100.26.64/27'
    sales: '10.100.23.0/27'
    sven: '10.100.53.0/27'
    avd: '10.100.56.0/24'
  }
  prod: {
    monitor: '10.100.27.64/27'
    sales: '10.100.24.0/27'
    sven: '10.100.54.0/27'
    avd: '10.100.57.0/24'
  }
}

var domains = [
  'privatelink.blob.core.windows.net'
  'privatelink.file.core.windows.net'
  'privatelink.queue.core.windows.net'
  'privatelink.table.core.windows.net'
  'privatelink.web.core.windows.net'
  'privatelink.vaultcore.azure.net'
]

var vmSize = {
  dev: 'Standard_B2s'
  stg: 'Standard_D8ds_v4'
  prod: 'Standard_D8ds_v4'
}
//Create EntraID Groups manually
var entraIdGroups = {
  'grp-rbac-sub-avd-dev-01-UserPermissions': '09cf7cc4-7e5d-4c75-96f4-4667c4a4f4fd'
  'grp-rbac-sub-avd-stg-01-UserPermissions': '4ed7f960-2b5d-4af6-9264-90d0d3539115'
  'grp-rbac-sub-avd-prod-01-UserPermissions': 'adab78f0-b419-4082-b222-867f03d5d328'
}

resource rgSpoke 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefixSpoke}-01'
  location: location
  tags: config.tags
}

module vnetM 'modules/vnet.bicep' = {
  name: 'vnet_${timestamp}'
  scope: rg
  params: {
    prefix: prefixSpoke
    location: location
    addressPrefixes: vnet.addressPrefixes
    subnets: vnet.subnets
    allowedSubnets: allowedSubnets[environment]
  }
}

resource rgMonitor 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefixMonitor}-01'
  location: location
  tags: config.tags
}

module log 'modules/log.bicep' = {
  scope: rgMonitor
  name: 'log_${timestamp}'
  params: {
    name: 'log-${prefixMonitor}-01'
    location: avdLocation
  }
}

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefix}-01'
  location: location
  tags: config.tags
}

resource rgSt 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefixSt}-01'
  location: location
  tags: union(config.tags, {
      System: 'Profile'
    })
}

resource rgDns 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: toLower('rg-${prefixDns}-01')
  location: location
  tags: union(config.tags, {
      System: 'DNS'
    })
}

module pdnsz 'modules/pdnsz.bicep' = [for (domain, i) in domains: {
  name: 'pdnsz${i}_${timestamp}'
  scope: rgDns
  params: {
    name: domain
    vnetName: vnetM.outputs.name
    vnetId: vnetM.outputs.id
  }
}]

module kv 'modules/kv.bicep' = {
  scope: rg
  name: 'kv_${timestamp}'
  params: {
    name: 'kv-${prefix}-001'
    location: location
    defaultAction: 'Deny'
    workspaceId: log.outputs.id
    allowedIPs: [
      '83.218.79.111/32'
      '188.150.96.111/32'
    ]
  }
}

module data 'modules/data.bicep' = {
  scope: rg
  name: 'data_${timestamp}'
  params: {
    location: avdLocation
    prefix: prefix
    workspaceName: log.name
    workspaceId: log.outputs.id
  }
}

module stAvd 'modules/st.bicep' = {
  scope: rgSt
  name: 'stAvd_${timestamp}'
  params: {
    name: 'st${replace(prefix, '-', '')}001'
    location: location
    kind: 'StorageV2'
    dnsRgName: rgDns.name
    snetId: snet['snet-pep'].id
    shares: []
    networkAcls: {
      resourceAccessRules: []
      ipRules: []
      defaultAction: 'deny'
    }
    privateEndpoints: [
      'file'
      'blob'
    ]
  }
}

module avd 'modules/avd.bicep' = {
  scope: rg
  name: 'avd_${timestamp}'
  params: {
    prefix: prefix
    location: avdLocation
    workspaceId: log.outputs.id
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-vmavd${environment}01'
  location: location
  tags: config.tags
}

module avail 'modules/avail.bicep' = {
  scope: rgVm
  name: 'avail-${timestamp}'
  params: {
    name: 'avail-vmavd${environment}01'
    location: location
  }
}

resource kvExisting 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: 'kv-${prefix}-01'
  scope: rg
}

module vm 'modules/vm.bicep' = [for (vm, i) in range(1, avdCount[environment]): {
  scope: rgVm
  name: 'vmavd${i + 1}_${timestamp}'
  params: {
    adminPassword: kvExisting.getSecret('vmavd')
    adminUsername: kvExisting.getSecret('vmuser')
    location: location
    name: vm < 9 ? 'vmavddev0${i + 1}' : 'vmavddev${i + 1}'
    tags: config.tags
    vmSize: vmSize[environment]
    snetId: snet['snet-vm'].id
    DataWinId: resourceId(subscription().subscriptionId, rg.name, 'Microsoft.Insights/dataCollectionRules', 'data-win-${prefix}-01')
    availabilitySetName: 'avail-vmavd${environment}01'
    registrationInfoToken: reference(resourceId(subscription().subscriptionId, rg.name, 'Microsoft.DesktopVirtualization/hostPools', 'vdpool-${prefix}-01'), '2021-01-14-preview').registrationInfo.token
    hostPoolName: 'vdpool-${prefix}-01'
  }
}]

module rbacUserLogin 'modules/rbac.bicep' = {
  name: 'rbac-UserLogin_${timestamp}'
  scope: rgVm
  params: {
    principalId: entraIdGroups['grp-rbac-sub-avd-${environment}-01-UserPermissions']
    roles: [
      'Virtual Machine User Login'
    ]
  }
}

module rbacOnOff1 'modules/rbac.bicep' = {
  name: 'rbac-OnOff1_${timestamp}'
  scope: rg
  params: {
    principalId: avdPrincipal
    roles: [
      'Desktop Virtualization Power On Contributor role'
    ]
  }
}

module rbacOnOff2 'modules/rbac.bicep' = {
  name: 'rbac-OnOff2_${timestamp}'
  scope: rgVm
  params: {
    principalId: avdPrincipal
    roles: [
      'Desktop Virtualization Power On Contributor role'
    ]
  }
}
