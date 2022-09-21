targetScope = 'subscription'

param param object

var affix = toLower('${param.tags.Application}-${param.tags.Environment}')
var environment = toLower(param.tags.Environment)

resource rgvnet01 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: param.location
  tags: param.tags
  name: 'rg-${affix}-01'
}

module vnet01 'vnet.bicep' = {
  scope: rgvnet01
  name: 'module-${affix}-vnet01'
  params: {
    addressPrefixes: param.vnet01.addressPrefixes
    dnsServers: param.vnet01.dnsServers
    location: rgvnet01.location
    name: 'vnet-${affix}-01'
    natGateway: param.vnet01.natGateway
    peerings: param.vnet01.peerings
    subnets: param.vnet01.subnets 
  }
}

resource rgvmimage 'Microsoft.Resources/resourceGroups@2021-04-01' existing =  {
  name: 'rg-vmimage01'
}

resource rgVmavd 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vm in range(0, param.avd.avdcount): {
  name: toLower('rg-vmavd${environment}${vm + 1}')
  location: param.location
  tags: {
    Application: 'AVD'
    Environment: param.tags.Environment
  }
}]

module vmavd 'vmavd.bicep' = [for (vm, i) in range(0, param.avd.avdcount): {
  scope: rgVmavd[i]
  name: 'module-vmavd${vm + 1}'
  params: {
    adminPassword: '12345678.abc'
    adminUsername: 'azadmin'
    imageReference: '${rgvmimage.id}/providers/Microsoft.Compute/images/${param.avd.imagename}'
    location: rgVmavd[i].location
    name: toLower('vmavd${environment}${vm + 1}')
    osDiskSizeGB: param.avd.osDiskSizeGB
    plan: {}
    tags: rgVmavd[i].tags
    vmSize: param.avd.vmSize
    vnet: vnet01.outputs.id
    subnetname: param.avd.subnetname
    privateIPAddress: '${param.avd.privateIPAddress}${vm + 10}'
  }
}]
