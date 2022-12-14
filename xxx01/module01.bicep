module vm 'modules/vm.bicep' = [for (vm, i) in param.vm: if (vm.name != 'vmcaprod01' && vm.name != 'vmfileprod01') {
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
    vnetname: vnet.outputs.name
    vnetrg: rg.name
  }
}]
