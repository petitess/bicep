/*
This is a simple deployment, using a parameter file.
- One VNET with Subnets connected to NSGs.
- Route tables
- 3 VMs
- Public IP adress(if set to "true")
*/
targetScope =   'subscription'

param location string = config.location.name
param config object
param virtualMachines array
param virtualNetwork object

var tags = {
  Company: config.company.name
  Environment: config.environment.name
}

var affix = {
  environment: toLower('${config.environment.affix}')
  environmentLocation: toLower('${config.environment.affix}-${config.location.affix}')
  environmentLocationAlt: toLower('${config.environment.affix}-${config.location.alt.affix}')
  environmentCompany: toLower('${config.environment.affix}-${config.company.affix}')
  environmentCompanyStripped: toLower('${config.environment.affix}${config.company.affix}')
}

resource rgInfra 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: toLower('rg-infra-${affix.environmentLocation}-01')
  location: location
  tags: union(tags, {
    Application: 'Infrastructure'
  })
}

resource rgVm 'Microsoft.Resources/resourceGroups@2021-04-01' = [for virtualMachine in virtualMachines: {
  name: toLower('rg-${virtualMachine.name}')
  location: location
  tags: union(tags, {
    Application: virtualMachine.tags.Application
  })
}]

module Vnet 'vnet.bicep' = {
  scope: rgInfra
  name: 'module-${affix.environment}-vnet'
  params: {
    addressPrefixes: virtualNetwork.addressPrefixes
    dnsServers: virtualNetwork.dnsServers
    location: rgInfra.location
    name: 'vnet-${affix.environmentLocation}-01'
    natGateway: virtualNetwork.natGateway
    subnets: virtualNetwork.subnets
  }
}

module vmAD 'vm.bicep' = [for (virtualMachine, i) in virtualMachines: {
  name: 'module-${affix.environment}-${virtualMachine.name}'
  scope: rgVm[i]
  params: {
    location: location
    AdminPassword: '12345678.abc'
    offer: virtualMachine.imageReference.offer
    publisher: virtualMachine.imageReference.publisher
    vmSize: virtualMachine.vmSize
    skus: virtualMachine.imageReference.sku
    networkInterfaces: virtualMachine.networkInterfaces
    name: virtualMachine.name
    tags: virtualMachine.tags
    vnetId: Vnet.outputs.vnetId
  }
}]



