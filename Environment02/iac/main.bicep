targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
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
  scope: rgAlt
  name: 'module-${affix}-alert01'
  params: {
    tags: param.tags
    actionGroupId: ag.outputs.agP5Bas
    location: param.locationAlt
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
    contributor: param.id.contributor
    keyvaultadmin: param.id.reader
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

resource rgAlt 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${affix}-we-01'
  location: param.locationAlt
  tags: param.tags
}

module vmScript 'modules/vmScript.bicep' = {
  scope: rgAlt
  name: 'module-${affix}-vmscript'
  params: {
    kvName: kv.outputs.name
    location: rgAlt.location
    name: 'vmScript-${affix}-01'
    vm: union(param.vm, param.vmadc, param.vmavail)
    idId: id.outputs.id
    idName: id.outputs.name
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2022-09-01' = [for vm in param.vm: {
  name: toLower('rg-${vm.name}')
  location: param.location
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vm 'modules/vm.bicep' = [for (vm, i) in param.vm: if (vm.name != 'vmcaprod01' && vm.name != 'vmfileprod01') {
  scope: rgVm[i]
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: kvExisting.getSecret(vm.name)
    adminUsername: kvExisting.getSecret(vmScript.outputs.adminUsername)
    ag: ag.outputs.agP3Bas
    availabilitySetName: vm.availname
    backup: vm.backup
    dataDisks: vm.dataDisks
    extensions: vm.extensions
    imageReference: vm.imageReference
    location: rgVm[i].location
    log: vmlog.outputs.id
    logApi: vmlog.outputs.api
    logLocation: vmlog.outputs.logLocation
    monitor: vm.monitor
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    OS: vm.OS
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    rsvDefaultPolicy: rsv.outputs.defaultPolicy
    rsvName: rsv.outputs.name
    rsvRg: rg.name
    rsvWeeklyPolicy: rsv.outputs.weeklyPolicy
    tags: union(rgVm[i].tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet.outputs.name
    vnetrg: rg.name
  }
}]

resource rgavail 'Microsoft.Resources/resourceGroups@2022-09-01' = [for rg in param.availabilitysets: {
  name: 'rg-${rg}'
  location: param.location
  tags: param.tags
}]

module avail 'modules/avail.bicep' = [for (avail, i) in param.availabilitysets: {
  scope: rgavail[i]
  name: 'module-vmavail'
  params: {
    location: param.location
    name: 'avail-${avail}'
  }
}]

module lb 'modules/lb.bicep' = {
  scope: resourceGroup('rg-vmadc${env}01')
  dependsOn: [
    rgavail
  ]
  name: 'module-${affix}-lb01'
  params: {
    location: param.location
    name: 'lb-adc-${env}-01'
  }
}

module lbi 'modules/lbi.bicep' = {
  scope: resourceGroup('rg-vmadc${env}01')
  name: 'module-${affix}-lbi01'
  params: {
    location: param.location
    name: 'lbi-adc-${env}-01'
    vdasubnetid: vnet.outputs.vdasubnetid
  }
}

module vmadc 'modules/vmadc.bicep' = [for (vmadc, i) in param.vmadc: {
  scope: rgavail[0]
  name: 'module-${vmadc.name}-vm'
  params: {
    adminPassword: kvExisting.getSecret(vmadc.name)
    adminUsername: kvExisting.getSecret(vmScript.outputs.adminUsername)
    ag: ag.outputs.agP3Bas
    availabilitySetName: 'avail-${param.availabilitysets[0]}'
    dataDisks: vmadc.dataDisks
    imageReference: vmadc.imageReference
    location: rgavail[0].location
    log: vmlog.outputs.id
    logLocation: vmlog.outputs.logLocation
    monitor: vmadc.monitor
    name: vmadc.name
    networkInterfaces: vmadc.networkInterfaces
    osDiskSizeGB: vmadc.osDiskSizeGB
    plan: vmadc.plan
    tags: union(rgavail[0].tags, vmadc.tags)
    vmSize: vmadc.vmSize
    vnetname: vnet.outputs.name
    vnetrg: rg.name
    loadBalancerBackendAddressPoolId: lb.outputs.poolid
    IloadBalancerBackendAddressPoolId: lbi.outputs.poolid
  }
}]

module vmavail 'modules/vm.bicep' = [for vm in param.vmavail: {
  scope: resourceGroup(vm.rgname)
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: kvExisting.getSecret(vm.name)
    adminUsername: kvExisting.getSecret(vmScript.outputs.adminUsername)
    ag: ag.outputs.agP3Bas
    availabilitySetName: vm.availname
    backup: vm.backup
    dataDisks: vm.dataDisks
    extensions: vm.extensions
    imageReference: vm.imageReference
    location: param.location
    log: vmlog.outputs.id
    logApi: vmlog.outputs.api
    logLocation: vmlog.outputs.logLocation
    monitor: vm.monitor
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    OS: vm.OS
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    rsvDefaultPolicy: rsv.outputs.defaultPolicy
    rsvName: rsv.outputs.name
    rsvRg: rg.name
    rsvWeeklyPolicy: rsv.outputs.weeklyPolicy
    tags: union(param.tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet.outputs.name
    vnetrg: rg.name
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
    aaname: aa.outputs.name
    aargname: rg.name
    rsvname: rsv.outputs.name
  }
}

module vgw 'modules/vgw.bicep' = if (param.vgw.update) {
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

resource rgvda 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: toLower('rg-vmvda${param.tags.Environment}01')
  location: param.location
  tags: param.tags
}

module datarules 'modules/datarules.bicep' = {
  scope: rg
  name: 'module-${affix}-datarules'
  params: {
    location: param.location
    name: '${affix}-sc01'
    workspacename: log.outputs.name
  }
}

module vmassociation 'modules/vmassociation.bicep' = [for (vmx, i) in param.vm: {
  scope: rgVm[i]
  dependsOn: [
    vm
  ]
  name: 'module-${affix}-vmassociation'
  params: {
    associationName: 'data-${vmx.name}'
    DataWinId: datarules.outputs.DataRuleWinId
    DataLinuxId: datarules.outputs.DataRuleLinuxId
    extensions: vmx.extensions
    publisher: vmx.imageReference.publisher
    vmname: vmx.name
  }
}]

module maintenance 'modules/maintenance.bicep' = {
  scope: rg
  name: 'module-${affix}-maintenance'
  params: {
    name: 'update-${affix}-01'
    location: param.location
  }
}
//Aktiveras när Azure Monitor Agent aktiveras
// module vmassignments 'modules/vmassignments.bicep' = [ for (vmx, i) in param.vm: if(vmx.name == 'vmmgmtprod01') {
//   scope: rgVm[i]
//   dependsOn: [
//     vm
//   ]
//   name: 'module-${vmx.name}-update'
//   params: {
//     maintenanceid: maintenance.outputs.maintenanceid
//     name: vmx.name
//     param: param
//   }
// }]

module appin 'modules/appinsight.bicep' = {
  scope: rg
  name: 'module-${affix}-appinsight'
  params: {
    name: 'appi-${affix}-01'
    location: param.location
    WorkspaceResourceId: log.outputs.id
    webtests: param.webtests
    actionGroupId: ag.outputs.agP3Bas
  }
}

resource rgitglue 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: param.location
  tags: union(param.tags, {
      Application: 'ITglue Integration'
    })
  name: 'rg-app-int-${env}-01'
}

module kvint 'modules/kvint.bicep' = {
  name: 'module-${env}-kvint'
  scope: rgitglue
  params: {
    name: param.itglueint.kvname
    location: param.location
    param: param
  }
}

module appitglueint 'modules/appitglueint.bicep' = {
  scope: rgitglue
  name: 'module-${affix}-appint'
  params: {
    appiconstring: appin.outputs.ConnectionString
    KeyVaultUrl: 'https://${param.itglueint.kvname}${environment().suffixes.keyvaultDns}/'
    location: param.location
    env: env
    keyvaultadmin: param.id.keyvaultadmin
  }
}

module sql 'modules/sqlint.bicep' = {
  scope: rgitglue
  name: 'module-${affix}-sqlint'
  params: {
    location: param.location
    env: env
    sqlpassword: kvint.outputs.pass
    groupsid: param.id.group.sid
    groupname: param.id.group.name
    kvname: kvint.outputs.name
  }
}
