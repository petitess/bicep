targetScope = 'subscription'

param config object
param vnet object
param environment string
param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location
param vms array

var prefixSpoke = toLower('${config.product}-spoke-${environment}-${config.location}')
var prefixMonitor = toLower('${config.product}-monitor-${environment}-${config.location}')
var snet = toObject(vnetM.outputs.subnets, subnet => subnet.name)
var allowedSubnets = {
  dev: {
    monitor: '10.100.25.64/27'
    sales: '10.100.22.0/27'
    sven: '10.100.52.0/27'
    avd: '10.100.55.0/24'
  }
  prod: {
    monitor: '10.100.27.64/27'
    sales: '10.100.24.0/27'
    sven: '10.100.54.0/27'
    avd: '10.100.57.0/24'
  }
}

resource rgSpoke 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: 'rg-${prefixSpoke}-01'
  location: location
  tags: union(config.tags, {
    System: 'VNET'
  })
}

resource rgMonitor 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: 'rg-${prefixMonitor}-01'
  location: location
  tags: union(config.tags, {
    System: 'Monitor'
  })
}

module log 'modules/log.bicep' = {
  scope: rgMonitor
  name: 'log_${timestamp}'
  params: {
    name: 'log-${prefixMonitor}-01'
    location: location
  }
}

module data 'modules/data.bicep' = {
  scope: rgMonitor
  name: 'data_${timestamp}'
  params: {
    location: location
    prefix: prefixMonitor
    workspaceResourceId: resourceId(
      subscription().subscriptionId,
      rgMonitor.name,
      'Microsoft.OperationalInsights/workspaces',
      'log-${prefixMonitor}-01'
    )
    workspaceName: 'log-${prefixMonitor}-01'
  }
}

module vnetM 'modules/vnet.bicep' = {
  name: 'vnet_${timestamp}'
  scope: rgSpoke
  params: {
    prefix: prefixSpoke
    location: location
    addressPrefixes: vnet.addressPrefixes
    subnets: vnet.subnets
    allowedSubnets: allowedSubnets[environment]
  }
}

resource rgAvail 'Microsoft.Resources/resourceGroups@2024-11-01' = [
  for avail in filter(vms, v => !empty(v.availabilitySetName) && contains(v.name, '01')): {
    name: toLower('rg-${avail.name}')
    location: location
    tags: config.tags
  }
]

module avail 'modules/avail.bicep' = [
  for (avail, i) in filter(vms, v => !empty(v.availabilitySetName) && contains(v.name, '01')): {
    scope: rgAvail[i]
    name: 'avail-${avail.name}_${timestamp}'
    params: {
      name: 'avail-${avail.name}'
      location: location
    }
  }
]

resource rgVm 'Microsoft.Resources/resourceGroups@2024-11-01' = [
  for vm in filter(vms, v => empty(v.availabilitySetName)): {
    name: toLower('rg-${vm.name}')
    location: location
    tags: config.tags
  }
]

module vm 'modules/vm.bicep' = [
  for (vm, i) in vms: {
    scope: resourceGroup(vm.rgName)
    name: '${vm.name}_${timestamp}'
    params: {
      adminPassword: '12345678.abc'
      adminUsername: 'azadmin'
      dataDisks: vm.dataDisks
      imageReference: vm.imageReference
      location: location
      name: vm.name
      networkInterfaces: vm.networkInterfaces
      osDiskSizeGB: vm.osDiskSizeGB
      plan: vm.plan
      tags: union(config.tags, vm.tags)
      vmSize: vm.vmSize
      snetId: snet['snet-mgmt'].id
      AzureMonitorAgentWin: vm.?AzureMonitorAgentWin ?? false
      AzureMonitorAgentLinux: vm.?AzureMonitorAgentLinux ?? false
      DataLinuxId: data.outputs.DataLinuxId
      DataWinId: data.outputs.DataWinId
      availabilitySetName: vm.availabilitySetName
      dataEndpointId: data.outputs.dataEndpointId
      dataVmInsightsId: data.outputs.DataVMInsightsId
    }
  }
]

output RgAvail array = [
  for avail in filter(vms, v => !empty(v.availabilitySetName) && contains(v.name, '01')): {
    name: avail.name
  }
]

output rgNoAvail array = [
  for vm in filter(vms, v => empty(v.availabilitySetName)): {
    name: vm.name
  }
]
