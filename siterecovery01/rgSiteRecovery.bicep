targetScope = 'subscription'

param env string
param param object

resource rgSiteRecovery 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-siterecovery-${env}-01'
  location: param.locationAsr
  tags: union(param.tags, {
      Application: 'Site Recovery'
    })
}

resource rgVm 'Microsoft.Resources/resourceGroups@2022-09-01' = [for vm in param.vms: if (vm.backup.siteRecovery) {
  name: toLower('rg-${vm.name}-asr')
  location: param.locationAsr
  tags: union(vm.tags, {
      Application: vm.tags.Application
      Environment: param.tags.Environment
    })
}]

output name string = rgSiteRecovery.name
output id string = rgSiteRecovery.id
