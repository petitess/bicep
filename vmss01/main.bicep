targetScope = 'subscription'

param environment string
param param object
param timestamp int = dateTimeToEpoch(utcNow())

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var prefixDevOps = toLower('${param.product}-devops-${environment}-${param.location}')
var env = toLower(param.tags.Environment)

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet 'vnet.bicep' = {
  scope: rg
  name: 'module-vnet'
  params: {
    addressPrefixes: param.vnet.addressPrefixes
    affix: affix
    location: param.location
    subnets: param.vnet.subnets
  }
}

module bastion 'bas.bicep' = if(false) {
  scope: rg
  name: 'module-bastion'
  params: {
    location: param.location
    name: 'bas-${env}-01'
    subnet: vnet.outputs.snet.AzureBastionSubnet.id
    vnet: vnet.outputs.id
  }
}

resource rgvmss 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: toLower('rg-vmss-${env}-01')
  location: param.location
  tags: {
    Application: 'VMSS DevOps'
    Environment: param.tags.Environment
  }
}

module vmss 'vmss.bicep' = [for (vm, i) in param.vmss: {
  scope: rgvmss
  name: 'vmss0${1 + i}_${timestamp}'
  params: {
    adminPass: '12345678.abc'//kv.getSecret(vm.name)
    adminUsername: 'admin'//kv.getSecret('adminUsername')
    computerNamePrefix: vm.name
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: param.location
    name: 'vmss-${prefixDevOps}-0${vm.instance}'
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    vmSize: vm.vmSize
    vnetName: vnet.name
    vnetRg: rg.name
    tags: union(param.tags, vm.tags)
  }
}]
