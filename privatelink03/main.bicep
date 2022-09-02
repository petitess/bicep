targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var location = param.location

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
    networkAcls: storage.networkAcls
  }
}]

module pefile 'pefile.bicep' = [for storage in param.st: if (storage.pe.enabled) {
  scope: rginfra
  name: 'module-${storage.name}-pe1'
  dependsOn: [
    st01
  ]
  params: {
    location: param.location
    name: 'pe-${storage.name}-file01'
    privateLinkServiceId: '${rginfra.id}/providers/Microsoft.Storage/storageAccounts/${storage.name}'
    subnet: vnet01.outputs.PeSubnetName
    vnet: vnet01.outputs.id
    filednsid: pdnsz.outputs.filednsis
  }
}]

module peblob 'peblob.bicep' = [for storage in param.st: if (storage.pe.enabled) {
  scope: rginfra
  name: 'module-${storage.name}-pe2'
  dependsOn: [
    st01
  ]
  params: {
    location: param.location
    name: 'pe-${storage.name}-blob01'
    privateLinkServiceId: '${rginfra.id}/providers/Microsoft.Storage/storageAccounts/${storage.name}'
    subnet: vnet01.outputs.PeSubnetName
    vnet: vnet01.outputs.id
    blobdnsid: pdnsz.outputs.blobdnsid
  }
}]

module pdnsz 'pdnsz.bicep' = {
  scope: rginfra
  name: 'module-${affix}-pdnsz'
  params: {
    vnet: vnet01.outputs.id
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

resource rgVm1 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vm in param.vmvnet01: {
  name: toLower('rg-${vm.name}')
  location: param.location
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vm1 'vm.bicep' = [for (vm, i) in param.vmvnet01: {
  scope: rgVm1[i]
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: '12345678.abC'
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
    vnet: vnet01.outputs.id
  }
}]



