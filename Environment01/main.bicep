targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)
var tags = param.tags
var subprefix = take(subscription().subscriptionId, 5)

resource rginfra 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${affix}-sc-01'
  location: param.location
  tags: tags
}

module vnet 'vnet.bicep' = {
  scope: rginfra 
  name: 'module-${env}-vnet01'
  params: {
    name: 'vnet-${env}-01'
    location: rginfra.location
    addressPrefixes: param.vnet.addressPrefixes
    dnsServers: param.vnet.dnsServers
    subnets: param.vnet.subnets
    natGateway: param.vnet.natGateway
    peerings: param.vnet.peerings
  }
}

module ag 'ag.bicep' = {
  scope: rginfra
  name: 'module-${env}-ag01'
  params: {
    name: replace('AG${env}01', '-', '')
    tags: tags
  }
}

module st01 'st.bicep' = [for storage in param.st: {
  scope: rginfra
  name: 'module-${storage.name}'
  params: {
    kind: storage.kind
    location: rginfra.location
    name: storage.name
    sku: storage.sku
    fileShares: storage.fileShares
    containers: storage.containers
    networkAcls: storage.networkAcls
  }
}]

module pe 'pe.bicep' =[for storage in param.st: if (storage.pe.enabled) {
  scope: rginfra
  name: 'module-pe-${storage.name}'
  dependsOn: st01
  params: {
    groupIds: storage.pe.groupIds
    location: rginfra.location
    name: 'pe-${storage.name}'
    privateLinkServiceId: resourceId(subscription().subscriptionId, rginfra.name, 'Microsoft.Storage/storageAccounts', storage.name)
    subnetid: resourceId(subscription().subscriptionId, rginfra.name, 'Microsoft.Network/virtualNetworks/subnets', vnet.outputs.name, param.st[0].pe.subnet)
  }
}]

module aa 'aa.bicep' = {
  scope: rginfra
  name: 'module-${env}-aa01'
  params: {
    location: rginfra.location
    name: 'aa-${env}-01'
    param: param
    idId: id.outputs.id
  }
}

module keyvault 'kv.bicep' = {
  scope: rginfra
  name: 'module-${env}-kv01'
  params: {
    location: rginfra.location
    kvname: 'kv-${subprefix}-${env}-01'
  }
}

resource rginfrawe 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${affix}-we-01'
  location: param.locationAlt
  tags: tags
}

module id 'id.bicep' = {
  scope: rginfrawe
  name: 'module-${env}-id01'
  params: {
    location: rginfrawe.location
    name: 'id-${subprefix}-${env}-01'
  }
}

module rbac 'rbac.bicep' = {
  name: 'module-${env}-rbac'
  params: {
    principalId: id.outputs.principalId
    role1: param.id.keyvaultadmin
    role2: param.id.contributor
  }
}

module script 'script.bicep' = {
  scope: rginfrawe
  dependsOn: [
    id
  ]
  name: 'module-${env}-script01'
  params: {
    location: rginfrawe.location
    name: 'script-${env}-01'
    idId: id.outputs.id
    kvName: keyvault.outputs.name
    virtualMachines: union(param.vms, param.vmavail)
  }
}

module datarules 'datarules.bicep' = {
  scope: rginfra
  name: 'module-${affix}-datarules'
  params: {
    location: param.location
    env: env
    workspacename: vmlog.outputs.workspaceName
  }
}

module maint01 'maintenance.bicep' = {
  scope: rginfra
  name: 'module-${env}-maintenance01'
  params: {
    name: 'update-${env}-01'
    location: rginfra.location
  }
}

module maint02 'maintenance.bicep' = {
  scope: rginfra
  name: 'module-${env}-maintenance02'
  params: {
    name: 'update-${env}-02'
    location: rginfra.location
  }
}

resource rgvm 'Microsoft.Resources/resourceGroups@2022-09-01' = [for vm in param.vms: {
  name: 'rg-${vm.name}'
  location: param.location
  tags: union(tags, {
    Application: vm.tags.Application
  })
}]

resource kvexisting 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyvault.outputs.name
  scope: rginfra
}

module vm 'vm.bicep' = [for (vm, i) in param.vms: {
  scope: rgvm[i]
  name: 'module-${vm.name}-vm'
  dependsOn: [
    script
  ]
  params: {
    adminPassword: kvexisting.getSecret(vm.name)
    adminUsername: kvexisting.getSecret(keyvault.outputs.username)
    ag: ag.outputs.actiongrpid
    availabilitySetName: vm.availname
    backup: vm.backup
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: rgvm[i].location
    log: vmlog.outputs.workspaceId
    logLocation: vmlog.outputs.logLocation
    maintenanceid: vm.tags.UpdateManagement == 'Critical_Monthly_GroupA' ? maint01.outputs.id : maint02.outputs.id
    monitor: vm.monitor
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    rsvDefaultPolicy: rsv.outputs.defaultPolicy
    rsvName: rsv.outputs.name
    rsvRg: rginfra.name
    rsvWeeklyPolicy: rsv.outputs.weeklyPolicy
    tags: union(rgvm[i].tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet.outputs.name
    vnetrg: rginfra.name
    DataLinuxId: datarules.outputs.DataRuleLinuxId
    DataWinId: datarules.outputs.DataRuleWinId
    LinuxOS: vm.LinuxOS
    WindowsOS: vm.WindowsOS
    UpdateMgmtV2: vm.UpdateMgmtV2
  }
}]

resource rgavail 'Microsoft.Resources/resourceGroups@2022-09-01' = [for rg in param.availabilitysets: {
  name: 'rg-${rg}'
  location: param.location
  tags: param.tags
}]

module avail 'avail.bicep' = [for (avail, i) in param.availabilitysets: {
  scope: rgavail[i]
  name: 'module-vmavail'
  params: {
    location: param.location
    name: 'avail-${avail}'
  }
}]

module vmdavail 'vm.bicep' = [for vm in param.vmavail: {
  scope: resourceGroup(vm.rgname)
  name: 'module-${vm.name}-vm'
  dependsOn: [
    script
  ]
  params: {
    adminPassword: kvexisting.getSecret(vm.name)
    adminUsername: kvexisting.getSecret(keyvault.outputs.username)
    ag: ag.outputs.actiongrpid
    availabilitySetName: vm.availname
    backup: vm.backup
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: param.location
    log: vmlog.outputs.workspaceId
    logLocation: vmlog.outputs.logLocation
    maintenanceid: vm.tags.UpdateManagement == 'Critical_Monthly_GroupA' ? maint01.outputs.id : maint02.outputs.id
    monitor: vm.monitor
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    rsvDefaultPolicy: rsv.outputs.defaultPolicy
    rsvName: rsv.outputs.name
    rsvRg: rginfra.name
    rsvWeeklyPolicy: rsv.outputs.weeklyPolicy
    tags: union(tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet.outputs.name
    vnetrg: rginfra.name
    DataLinuxId: datarules.outputs.DataRuleLinuxId
    DataWinId: datarules.outputs.DataRuleWinId
    LinuxOS: vm.LinuxOS
    WindowsOS: vm.WindowsOS
    UpdateMgmtV2: vm.UpdateMgmtV2
  }
}]

module vmlog 'vmlog.bicep' = {
  scope: rginfra
  name: 'module-${env}-log01'
  params: {
    location: rginfra.location
    name: 'log-vm-${env}-01'
    aaid: aa.outputs.aaId
  }
}

module rsv 'rsv.bicep' = {
  scope: rginfra
  name: 'module-${affix}-rsv'
  params: {
    daysOfTheWeek: param.rsv.daysOfTheWeek
    location: param.location
    name: 'rsv-${affix}-01'
    sku: param.rsv.sku
    retentionDays: param.rsv.retentionDays
    retentionTimes: param.rsv.retentionTimes
    retentionWeeks: param.rsv.retentionWeeks
    scheduleRunTimes: param.rsv.scheduleRunTimes
  }
}

module bas 'bastion.bicep' = if(param.bastion.deploy) {
  scope: rginfra
  name: 'module-${env}-bastion01'
  params: {
    name: 'bas-${vnet.outputs.name}'
    location: rginfra.location
    subnet: vnet.outputs.BastionSubnetId
  }
}

module diag 'diag.bicep' = {
  name: 'module-${env}-diag01'
  params: {
    name: 'log-activity-${env}-01'
    workspaceId: vmlog.outputs.workspaceId
  }
}

module nw 'nw.bicep' = {
  scope: rginfra
  name: 'module-${env}-nw01'
  params: {
    location: rginfra.location
    name: 'nw-${env}-01'
    virtualMachines: param.vms
    workspaceResourceId: vmlog.outputs.workspaceId
    actionGroupId: ag.outputs.actiongrpid 
  }
}

module vgw 'vgw.bicep' = if(param.vgw.deploy) {
  scope: rginfra
  name: 'module-${env}-vgw01'
  params: {
    location: rginfra.location
    lgwname: 'lgw-${env}-01'
    vgwname: 'vgw-${env}-01'
    param: param
    subnetid: vnet.outputs.GatewaySubnetId
  }
}
