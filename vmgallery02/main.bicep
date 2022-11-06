targetScope = 'subscription'

param param object

@description('Change to true when an image is prepared. Remove vmimage01 after creating an image')
param sysprepReady bool = param.gallery.sysprepReady

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var env = toLower(param.tags.Environment)

resource rginfra 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet01 'vnet.bicep' = {
  scope: rginfra
  name: 'module-${affix}-vnet01'
  params: {
    addressPrefixes: param.vnet01.addressPrefixes
    dnsServers: param.vnet01.dnsServers
    location: param.location
    name: 'vnet-${affix}-01'
    natGateway: param.vnet01.natGateway
    peerings: param.vnet01.peerings
    subnets: param.vnet01.subnets 
  }
}

module bas 'bas.bicep' = {
  scope: rginfra
  name: 'module-${affix}-bas'
  params: {
    location: param.location
    name: 'bas-${vnet01.outputs.name}'
    subnet: '${vnet01.outputs.id}/subnets/AzureBastionSubnet'
  }
}

resource rgimage 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vm in param.vmimage: {
  name: toLower('rg-${vm.name}')
  location: param.location
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vmimage 'vm.bicep' = [for (vm, i) in param.vmimage: if(sysprepReady == false) {
  scope: rgimage[i]
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: '12345678.abc'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: rgimage[i].location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgimage[i].tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet01.outputs.name
    vnetrg: rginfra.name
  }
}]

resource rggal 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  location: param.location
  tags: param.tags
  name: 'rg-gal-${env}-01'
}
//Run sysprep and generalize VM first
module vmgal 'vmgal.bicep' = if(sysprepReady) {
  scope: rggal
  name: 'module-${env}-gallery'
  params: {
    location: param.location
    name: 'gal${env}01'
    param: param
  }
}

resource rgVmavd 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vm in range(0, param.avd.avdcount): if(sysprepReady) {
  name: toLower('rg-vmavd${env}${vm + 1}')
  location: param.location
  tags: {
    Application: 'AVD'
    Environment: param.tags.Environment
  }
}]

module vmavd 'vmavd.bicep' = [for (vm, i) in range(0, param.avd.avdcount): if(sysprepReady) {
  scope: rgVmavd[i]
  name: 'module-vmavd${vm + 1}'
  params: {
    adminPassword: '12345678.abc'
    adminUsername: 'azadmin'
    imageReference: vmgal.outputs.imageid
    location: rgVmavd[i].location
    name: toLower('vmavd${env}${vm + 1}')
    osDiskSizeGB: param.avd.osDiskSizeGB
    plan: {}
    tags: rgVmavd[i].tags
    vmSize: param.avd.vmSize
    vnetname: vnet01.outputs.name
    vnetrg: rginfra.name
    subnetname: param.avd.subnetname
    privateIPAddress: '${param.avd.privateIPAddress}${vm + 20}'
  }
}]
