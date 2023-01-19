targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var location = param.location

resource rginfra 'Microsoft.Resources/resourceGroups@2022-09-01' ={
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

module st01 'st.bicep' = [for storage in param.st: {
  scope: rginfra
  name: 'module-${storage.name}'
  params: {
    kind: storage.kind
    location: location
    name: storage.name
    sku: storage.sku
    fileShares: storage.fileShares
    containers: storage.containers
    queues: storage.queues
    tables: storage.tables
    networkAcls: storage.networkAcls
  }
}]

module pe 'pe.bicep' = [for storage in param.st:{
  scope: rginfra
  name: 'module-${storage.name}-pe'
  dependsOn: [
    st01
  ]
  params: {
    blob: storage.privateEndpoints.blob
    blobdnsid: pdnsz.outputs.blobdnsid
    file: storage.privateEndpoints.file
    filednsid: pdnsz.outputs.filednsis
    location: param.location
    queue: storage.privateEndpoints.queue
    queuednsid: pdnsz.outputs.queuednsis
    rgstname: rginfra.name
    stname: storage.name
    subnet: vnet01.outputs.PeSubnetName
    table: storage.privateEndpoints.table
    tablednsid: pdnsz.outputs.tablednsid
    vnetname: vnet01.outputs.name
  }
}]

module pdnsz 'pdnsz.bicep' = {
  scope: rginfra
  name: 'module-${affix}-pdnsz'
  params: {
    vnet: vnet01.outputs.id
  }
}

module bas 'bas.bicep' = if(param.bastionDeploy) {
  scope: rginfra
  name: 'module-${affix}-bas'
  params: {
    location: param.location
    name: 'bas-${vnet01.outputs.name}'
    vnetname: vnet01.outputs.name
  }
}

resource rgVm1 'Microsoft.Resources/resourceGroups@2022-09-01' = [for vm in param.vm: if(param.VMsDeploy) {
  name: toLower('rg-${vm.name}')
  location: param.location
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vm1 'vm.bicep' = [for (vm, i) in param.vm: if(param.VMsDeploy) {
  scope: param.VMsDeploy ? rgVm1[i] : rginfra
  name: 'module-${vm.name}-vm'
  params: {
    adminPass: '12345678.abC'
    adminUsername: 'azadmin'
    dataDisks: vm.dataDisks
    imageReference: vm.imageReference
    location: rgVm1[i].location
    name: vm.name
    networkInterfaces: vm.networkInterfaces
    osDiskSizeGB: vm.osDiskSizeGB
    plan: vm.plan
    tags: union(rgVm1[i].tags, vm.tags)
    vmSize: vm.vmSize
    vnetname: vnet01.outputs.name
    vnetrg: rginfra.name
  }
}]



