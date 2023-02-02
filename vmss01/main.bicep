targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' ={
  location: param.location
  tags: param.tags
  name: 'rg-infra-${affix}-01'
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'module-${affix}-vnet01'
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

module bas 'bas.bicep' = if(param.bastion) {
  scope: rg
  name: 'module-${affix}-bas'
  params: {
    location: param.location
    name: 'bas-${vnet.outputs.name}'
    vnetname: vnet.outputs.name
  }
}

resource rgvmss 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: toLower('rg-vmss-${env}-01')
  location: param.location
  tags: {
    Application: 'VM Scale Sets'
    Environment: param.tags.Environment
  }
}

module lb 'lb.bicep' = [for (vm, i) in param.vmss: if(vm.networkInterfaces[0].externalloadbalancer) {
  scope: rgvmss
  name: 'module-${affix}-lb${i + 1}'
  params: {
    backendAddressPools: param.lb.backendAddressPools
    location: param.location
    name: 'lb-${vm.name}'
    probes: param.lb.probes
  }
}]

module vmss 'vmss.bicep' = [for (vm, i) in param.vmss: {
  scope: rgvmss
  name: 'module-${vm.name}-vm'
  params: {
    adminPass: '12345678.abc'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: rgvmss.location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgvmss.tags, vm.tags)
    vmSize: vm.vmSize
    DeployIIS: vm.DeployIIS
    vnetname: vnet.outputs.name
    vnetrg: rg.name
    extloadbalancerpoolid: lb[i].outputs.poolid
  }
}]

