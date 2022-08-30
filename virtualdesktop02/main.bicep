targetScope = 'subscription'

param param object
var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var environment = toLower(param.tags.Environment)

resource rgvnet01 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.locationAlt
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet01 'vnet.bicep' = {
  scope: rgvnet01
  name: 'module-${affix}-vnet01'
  params: {
    addressPrefixes: param.vnet01.addressPrefixes
    dnsServers: param.vnet01.dnsServers
    location: param.locationAlt
    name: 'vnet-${affix}-01'
    natGateway: param.vnet01.natGateway
    peerings: param.vnet01.peerings
    subnets: param.vnet01.subnets 
  }
}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-aadds-${environment}-01'
  location: param.locationAlt
}

module aadds  'aadds.bicep' = {
  scope: rg
  name: 'module-aadds-01'
  params: {
    subnetId: vnet01.outputs.AADDSubId
    location: param.locationAlt
    name: 'aadds-${affix}-01'
    domainName: param.aadds.domainname
    sku: param.aadds.sku
    notificationSettings: param.aadds.notificationSettings
  }
}

resource rgVm 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vm in param.vmvnet01: {
  name: toLower('rg-${vm.name}')
  location: param.locationAlt
  tags: {
    Application: vm.tags.Application
    Environment: param.tags.Environment
  }
}]

module vm1 'vm.bicep' = [for (vm, i) in param.vmvnet01: {
  scope: rgVm[i]
  name: 'module-${vm.name}-vm'
  params: {
    adminPassword: '12345678.abc'
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
    vnet: vnet01.outputs.id
    ADDservices: vm.ADDservices
  }
}]

// module vmext 'vmext.bicep' = [for (vm, i) in param.vmvnet01: if(vm.JoinDomain) {
//   scope: rgVm[i]
//   name: 'module-${vm.name}-vmext'
//   dependsOn: [
//     aadds
//     vm1
//   ]
//   params: {
//     // adminPassword: '12345678.abc'
//     // adminUsername: 'azadmin'
//     // domainFQDN: 
//     location: param.locationAlt
//     name: vm.name
//   }
// }]
resource rgavd 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.locationAlt
  tags: param.tags
  name: toLower('rg-avd-${param.tags.Environment}-01')
}

module avd 'avd.bicep' = {
  scope: rgavd
  name: 'module-${affix}-avd'
  params: {
    location: param.locationAlt
    name: 'AVDHP'
  }
}



