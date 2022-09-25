targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${affix}-sc-01'
  location: param.location
  tags: param.tags
}

module log 'modules/log.bicep' = {
  name: 'module-${affix}-log'
  scope: rg
  params: {
    name: 'log-${affix}-01'
    location: param.location
    sku: param.log.sku
    retentionInDays: param.log.retention
    solutions: param.log.solutions
    events: param.log.events
  }
}

module ag 'modules/ag.bicep' = {
  scope: rg
  name: 'module-${affix}-ag'
  params: {
    location: 'global'
  }
}

module alert 'modules/alert.bicep' = {
  scope: rg
  name: 'module-${affix}-alert01'
  params: {
    tags: param.tags
    actionGroupId: ag.outputs.agP5Bas
  }
}

module st 'modules/st.bicep' = [for storage in param.st: {
  scope: rg
  name: 'module-${storage.name}-st'
  params: {
    kind: storage.kind
    location: param.location
    name: storage.name
    networkAcls: storage.networkAcls
    sku: storage.sku
    fileShares: storage.fileshares
    containers: storage.containers
  }
}]

module aa 'modules/aa.bicep' = {
  scope: rg
  name: 'module-${affix}-aa'
  params: {
    location: param.location
    name: 'aa-${affix}-01'
  }
}

module kv 'modules/kv.bicep' = {
  scope: rg
  name: 'module-${affix}-kv'
  params: {
    location: param.location
    name: 'kv-comp-${affix}-01'
    sku: param.kv.sku
    enabledForDeployment: param.kv.enabledForDeployment
    enabledForDiskEncryption: param.kv.enabledForDiskEncryption
    enabledForTemplateDeployment: param.kv.enabledForTemplateDeployment
    enableRbacAuthorization: param.kv.enableRbacAuthorization
  }
}

resource kvExisting 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  scope: resourceGroup(rg.name)
  name: toLower('kv-comp-${affix}-01')
}

module rsv 'modules/rsv.bicep' = {
  scope: rg
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
    timeZone: param.rsv.timeZone
  }
}

module nw 'modules/nw.bicep' = {
  scope: rg
  name: 'module-${affix}-nw'
  params: {
    location: param.location
    name: 'nw-${affix}-01'
  }
}

module vnet 'modules/vnet.bicep' = {
  scope: rg
  name: 'module-${affix}-vnet'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    dnsServers: param.vnet.dnsServers
    location: param.location
    name: 'vnet-${affix}-01'
    natGateway: param.vnet.natGateway
    peerings: param.vnet.peerings
    subnets: param.vnet.subnets
  }
}

module bas 'modules/bas.bicep' = {
  scope: rg
  name: 'module-${affix}-bas'
  params: {
    location: param.location
    name: 'bas-${vnet.outputs.name}'
    subnet: '${vnet.outputs.id}/subnets/AzureBastionSubnet'
  }
}

module pe 'modules/pefile.bicep' = [for storage in param.st: if (storage.pe.enabled) {
  scope: rg
  name: 'module-${storage.name}-pe1'
  params: {
    location: param.location
    name: 'pe-${storage.name}-file01'
    privateLinkServiceId: '${rg.id}/providers/Microsoft.Storage/storageAccounts/${storage.name}'
    subnet: storage.pe.subnet
    vnetname: vnet.outputs.name
    filednsid: pdnsz.outputs.filednsid
  }
  dependsOn: st
}]

module pe2 'modules/peblob.bicep' = [for storage in param.st: if (storage.pe.enabled) {
  scope: rg
  name: 'module-${storage.name}-pe2'
  params: {
    location: param.location
    name: 'pe-${storage.name}-blob01'
    privateLinkServiceId: '${rg.id}/providers/Microsoft.Storage/storageAccounts/${storage.name}'
    subnet: storage.pe.subnet
    vnetname: vnet.outputs.name
    blobdnsid: pdnsz.outputs.blobdnsid
  }
  dependsOn: st
}]

module pdnsz 'modules/pdnsz.bicep' = {
  scope: rg
  name: 'module-${affix}-pdnsz'
  params: {
    filednsname: param.pe.filednsname
    blobdnsname: param.pe.blobdnsname
    vnet: vnet.outputs.id
  }
}

module id 'modules/id.bicep' = {
  scope: rg
  name: 'module-${affix}-id'
  params: {
    location: param.location
    name: 'id-${affix}-01'
  }
}

module rbac 'modules/rbac.bicep' = {
  name: 'module-${affix}-rbac'
  params: {
    principalId: id.outputs.principalId
    keyvaultadmin: param.id.keyvaultadmin
    contributor: param.id.contributor
  }
}

resource rgAlt 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${affix}-we-01'
  location: param.locationAlt
  tags: param.tags
}

module vmScript 'modules/vmScript.bicep' = {
  scope: rgAlt
  name: 'module-${affix}-script'
  params: {
    kvName: kv.outputs.name
    location: rgAlt.location
    name: 'vmScript-${affix}-01'
    vm: param.vm
    vmadc: param.vmadc
    idId: id.outputs.id
    idName: id.outputs.name
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vm in param.vm: {
  name: toLower('rg-${vm.name}')
  location: param.location
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vm 'modules/vm.bicep' = [for (vm, i) in param.vm: {
  scope: rgVm[i]
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: kvExisting.getSecret(vm.name)
    adminUsername: kvExisting.getSecret(vmScript.outputs.adminUsername)
    ag: ag.outputs.agP3Bas
    backup: vm.backup
    dataDisks: vm.dataDisks
    extensions: vm.extensions
    imageReference: vm.imageReference
    location: rgVm[i].location
    log: vmlog.outputs.id
    logApi: vmlog.outputs.api
    logRg: rgAlt.name
    logLocation: vmlog.outputs.logLocation
    monitor: vm.monitor
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    rsvDefaultPolicy: rsv.outputs.defaultPolicy
    rsvName: rsv.outputs.name
    rsvRg: rg.name
    rsvWeeklyPolicy: rsv.outputs.weeklyPolicy
    tags: union(rgVm[i].tags, vm.tags)
    vmSize: vm.vmSize
    vnet: vnet.outputs.id
  }
}]

resource rgVmAdc 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vm in param.vmadc: {
  name: toLower('rg-${vm.name}')
  location: param.location
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vmadc 'modules/vmadc.bicep' = [for (vm, i) in param.vmadc: {
  scope: rgVmAdc[i]
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: kvExisting.getSecret(vm.name)
    adminUsername: kvExisting.getSecret(vmScript.outputs.adminUsername)
    ag: ag.outputs.agP3Bas
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: rgVmAdc[i].location
    log: vmlog.outputs.id
    logRg: rgAlt.name
    logLocation: vmlog.outputs.logLocation
    monitor: vm.monitor
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgVmAdc[i].tags, vm.tags)
    vmSize: vm.vmSize
    vnet: vnet.outputs.id
  }
}]

module script 'modules/script.bicep' = {
  scope: rgAlt
  name: 'module-${affix}-script-infra'
  params: {
    idId: id.outputs.id
    idName: id.outputs.name
    kvName: kv.outputs.name
    location: rgAlt.location
    name: 'InfraScript-${affix}-01'
    param: param
  }
}

module vgw 'modules/vgw.bicep' = {
  scope: rg
  name: 'module-${affix}-vgw'
  params: {
    lgwname: 'lgw-${affix}-01'
    param: param
    sharedKey: kvExisting.getSecret(script.outputs.consecret)
    subnetid: vnet.outputs.GatewaySubnetId
    vgwname: 'vgw-${affix}-01'
  }
}

module vmlog 'modules/vmLog.bicep' = {
  scope: rgAlt
  name: 'module-${affix}-vmlog'
  params: {
    location: rgAlt.location
    name: 'log-vm-${affix}-01'
    aaid: vmaa.outputs.aaid
  }
}

module vmaa 'modules/vmAa.bicep' = {
  scope: rgAlt
  name: 'module-${affix}-vmaa'
  params: {
    location: rgAlt.location
    name: 'aa-vm-${affix}-01'
    updateSchedules: param.updateSchedules
  }
}

module terms 'modules/terms.bicep' = {
  scope: rgAlt
  name: 'module-${affix}-script-terms'
  params: {
    idId: id.outputs.id
    idName: id.outputs.name
    location: rgAlt.location
    name: 'TermsScript-${affix}-01'
  }
}

resource rgvda 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: toLower('rg-vmvda${param.tags.Environment}01')
  location: param.location
  tags: param.tags
}

