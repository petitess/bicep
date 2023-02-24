targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')

var deployVnet = true 
var deloyBastion = false  
var deployVm = true 
var deployAfw = true 
var deployAgw = true
var deployDns = true

resource rginfra1 'Microsoft.Resources/resourceGroups@2022-09-01' ={
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet01 'vnet.bicep' = if(deployVnet) {
  scope: rginfra1
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

module bas 'bas.bicep' = if(deloyBastion) {
  scope: rginfra1
  name: 'module-${affix}-bas'
  params: {
    location: param.location
    name: 'bas-${vnet01.outputs.name}'
    vnetname: vnet01.outputs.name
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

module vm1 'vm.bicep' = [for (vm, i) in param.vm: if (deployVm) {
  scope: rgVm[i]
  name: 'module-${vm.name}-vm'
  params: {
    adminPass: '12345678.abc'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: rgVm[i].location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgVm[i].tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet01.outputs.name
    vnetrg: rginfra1.name
    extensions: vm.extensions
    applicationGatewayBackendAddressPoolsId: agw.outputs.backendpool1id
  }
}]

module afw 'afw.bicep' = if(deployAfw) {
  scope: rginfra1
  name: 'module-${affix}-afw01'
  params: {
    location: param.location
    affix: affix
    name: 'afw-${affix}-01'
    vnetname: vnet01.outputs.name
  }
}

module agw 'agw.bicep' = if(deployAgw) {
  scope: rginfra1
  name: 'module-${affix}-agw'
  params: {
    location: param.location
    name: 'agw-${affix}-02'
    subnetid: vnet01.outputs.AgwSubId
    }
}

module pdnsz 'pdnsz.bicep' = if(deployDns) {
  scope: rginfra1
  name: 'module-pdnsz-01'
  params: {
    vnetid: vnet01.outputs.id
  }
}
