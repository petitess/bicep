targetScope = 'subscription'

param param object
param env string

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var location = param.location
var tags = param.tags
var unique = take(subscription().subscriptionId, 5)

resource rgInfra 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${affix}-01'
  location: location
  tags: tags
}

module vnet 'vnet.bicep' = {
  scope: rgInfra
  name: 'module-${env}-vnet01'
  params: {
    name: 'vnet-${env}-01'
    location: location
    addressPrefixes: param.vnet.addressPrefixes
    dnsServers: param.vnet.dnsServers
    subnets: param.vnet.subnets
    natGateway: param.vnet.natGateway
    peerings: param.vnet.peerings
  }
}

module ag 'ag.bicep' = {
  scope: rgInfra
  name: 'module-${env}-ag'
  params: {
    name: replace('AG${env}01', '-', '')
    tags: tags
  }
}

module st 'st.bicep' = [for storage in param.st: {
  scope: rgInfra
  name: 'module-${storage.name}'
  params: {
    location: location
    name: storage.name
    sku: storage.sku
    containersCount: storage.containersCount
    publicNetworkAccess: storage.publicNetworkAccess
    shares: storage.shares
    snetId: vnet.outputs.snet['snet-pe-prod-01'].id
  }
}]

module aa 'aa.bicep' = {
  scope: rgInfra
  name: 'module-${env}-aa'
  params: {
    location: location
    name: 'aa-${env}-01'
    idId: id.outputs.id
  }
}

module kv 'kv.bicep' = {
  scope: rgInfra
  name: 'module-${env}-kv'
  params: {
    location: location
    kvname: 'kv-${unique}-${env}-01'
  }
}

module id 'id.bicep' = {
  scope: rgInfra
  name: 'module-${env}-id'
  params: {
    location: location
    name: 'id-${unique}-${env}-01'
  }
}

module rbac 'rbac.bicep' = {
  name: 'module-${env}-rbac'
  params: {
    principalId: id.outputs.principalId
    roles: [
      'Contributor'
      'Key Vault Administrator'
    ]
  }
}

module script 'script.bicep' = {
  scope: rgInfra
  name: 'module-${env}-script'
  params: {
    location: location
    name: 'ds-vm-${env}-01'
    idId: id.outputs.id
    kvName: kv.outputs.name
    virtualMachines: param.vms
  }
}

module datarules 'datarules.bicep' = {
  scope: rgInfra
  name: 'module-${env}-datarules'
  params: {
    location: location
    env: env
    workspaceName: vmlog.outputs.workspaceName
  }
}

module maint01 'maintenance.bicep' = {
  scope: rgInfra
  name: 'module-${env}-maintenance01'
  params: {
    name: 'update-${env}-01'
    location: location
  }
}

module maint02 'maintenance.bicep' = {
  scope: rgInfra
  name: 'module-${env}-maintenance02'
  params: {
    name: 'update-${env}-02'
    location: location
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2022-09-01' = [for rg in param.noAvailabilitySets: {
  name: 'rg-${rg}'
  location: location
  tags: tags
}]

resource rgAvail 'Microsoft.Resources/resourceGroups@2022-09-01' = [for rg in param.availabilitySets: {
  name: 'rg-${rg}'
  location: location
  tags: tags
}]

module avail 'avail.bicep' = [for avail in param.availabilitySets: {
  scope: resourceGroup('rg-${avail}')
  name: 'module-${avail}-avail'
  params: {
    location: location
    name: 'avail-${avail}'
  }
}]

resource kvexisting 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: kv.outputs.name
  scope: rgInfra
}

module vm 'vm.bicep' = [for vm in param.vms: {
  scope: resourceGroup(vm.rgName)
  name: 'module-${vm.name}'
  params: {
    adminPassword: kvexisting.getSecret(vm.name)
    adminUsername: kvexisting.getSecret(kv.outputs.username)
    ag: ag.outputs.actionGrpId
    availabilitySetName: vm.availName
    backup: vm.backup
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: location
    log: vmlog.outputs.workspaceId
    logLocation: vmlog.outputs.logLocation
    maintenanceId: vm.tags.UpdateManagement == 'Critical_Monthly_GroupA' ? maint01.outputs.id : maint02.outputs.id
    monitor: vm.monitor
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    rsvDefaultPolicy: rsv.outputs.defaultPolicy
    rsvName: rsv.outputs.name
    infraRg: rgInfra.name
    tags: union(tags, vm.tags)
    vmSize: vm.vmSize
    vnetName: vnet.outputs.name
    DataLinuxId: datarules.outputs.DataRuleLinuxId
    DataWinId: datarules.outputs.DataRuleWinId
    LinuxOS: vm.LinuxOS
    WindowsOS: vm.WindowsOS
    UpdateMgmtV2: vm.UpdateMgmtV2
  }
}]

module vmlog 'vmlog.bicep' = {
  scope: rgInfra
  name: 'module-${env}-log'
  params: {
    location: location
    name: 'log-vm-${env}-01'
    aaId: aa.outputs.aaId
  }
}

module rsv 'rsv.bicep' = {
  scope: rgInfra
  name: 'module-${env}-rsv'
  params: {
    location: location
    name: 'rsv-${affix}-01'
    sku: param.rsv.sku
    retentionDays: param.rsv.retentionDays
    scheduleRunTimes: param.rsv.scheduleRunTimes
  }
}

module bas 'bastion.bicep' = if (false) {
  scope: rgInfra
  name: 'module-${env}-bastion'
  params: {
    name: 'bas-${vnet.outputs.name}'
    location: location
    subnet: vnet.outputs.snet.AzureBastionSubnet
    vnetId: vnet.outputs.id
  }
}

module vgw 'vgw.bicep' = if (param.vgw.deploy) {
  scope: rgInfra
  name: 'module-${env}-vgw'
  params: {
    location: location
    env: env
    vgwName: 'vgw-${env}-01'
    param: param
    subnetId: vnet.outputs.snet.GatewaySubnet
  }
}
