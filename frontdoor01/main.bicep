targetScope = 'subscription'

param config object
param env string
param location string
param vnet object
param vms array
param frontdoorEndpoints array

var prefix = toLower('${config.product}-${env}-${config.location}')
var prefixSpoke = toLower('${config.product}-spoke-${env}-${config.location}')

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${prefix}-01'
  location: location
  tags: config.tags
}

module vnetM 'modules/vnet.bicep' = {
  name: 'vnet'
  scope: rg
  params: {
    prefix: prefixSpoke
    location: location
    addressPrefixes: vnet.addressPrefixes
    subnets: vnet.subnets
  }
}

resource rgAvail 'Microsoft.Resources/resourceGroups@2024-03-01' = [
  for avail in filter(vms, v => !empty(v.availabilitySetName) && contains(v.name, '01')): {
    name: toLower('rg-${avail.name}')
    location: location
    tags: config.tags
  }
]

module avail 'modules/avail.bicep' = [
  for (avail, i) in filter(vms, v => !empty(v.availabilitySetName) && contains(v.name, '01')): {
    scope: rgAvail[i]
    name: 'avail-${avail.name}'
    params: {
      name: 'avail-${avail.name}'
      location: location
    }
  }
]

resource rgVm 'Microsoft.Resources/resourceGroups@2024-03-01' = [
  for vm in filter(vms, v => empty(v.availabilitySetName)): {
    name: toLower('rg-${vm.name}')
    location: location
    tags: config.tags
  }
]

resource rgAfd 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-afd-${env}-01'
  location: location
  tags: union(config.tags, {
    Application: 'Front Door'
  })
}

module afd 'modules/afd.bicep' = {
  scope: rgAfd
  name: 'afd'
  params: {
    name: 'afd-${env}-01'
  }
}

module fdendpoint 'modules/adf-fde.bicep' = [
  for fde in frontdoorEndpoints: {
    scope: rgAfd
    name: 'fde-${fde.appName}'
    params: {
      location: location
      env: env
      appName: fde.appName
      plServiceId: resourceId(
        contains(fde, 'appGroupId') && !empty(fde.appGroupId) ? fde.subscriptionId : subscription().subscriptionId,
        contains(fde, 'appGroupId') && !empty(fde.appGroupId) ? fde.appRg : rgAfd.name,
        contains(fde, 'appGroupId') && !empty(fde.appGroupId) ? fde.resourceType : rgAfd.type,
        contains(fde, 'appGroupId') && !empty(fde.appGroupId) ? fde.appName : rgAfd.name
      )
      customDomain: contains(fde, 'customDomain') ? fde.customDomain : ''
      DnsZoneId: resourceId(subscription().subscriptionId, rg.name, 'Microsoft.Network/dnszones', fde.DnsZoneName)
      customRules: fde.customRules
      isCompressionEnabled: fde.isCompressionEnabled
      queryStringCachingBehavior: fde.queryStringCachingBehavior
      certificateName: contains(fde, 'certificateName') ? fde.certificateName : ''
      rules: contains(fde, 'rules') ? fde.rules : []
      origins: fde.origins
      probePath: contains(fde, 'probePath') ? fde.probePath : '/'
      probeProtocol: contains(fde, 'probeProtocol') ? fde.probeProtocol : 'Https'
      forwardingProtocol: contains(fde, 'forwardingProtocol') ? fde.forwardingProtocol : 'HttpsOnly'
    }
    dependsOn: [
      afd
    ]
  }
]

module publicDns 'modules/adf-dns.bicep' = [
  for (fde, i) in frontdoorEndpoints: if (!contains(fde, 'DnsZoneName') || !empty(fde.DnsZoneName)) {
    scope: rg
    name: 'dns-${fde.appName}'
    params: {
      name: fde.DnsZoneName
      deployCNAME: fde.deployCNAME
      Cname: fde.deployCNAME ? replace(fde.customDomain, '.${fde.DnsZoneName}', '') : 'x'
      CnameValue: fdendpoint[i].outputs.endpointUrl
      TXTname: '_dnsauth.${replace(fde.customDomain, '.${fde.DnsZoneName}', '')}'
      TXTValue: fdendpoint[i].outputs.token
    }
  }
]

module vmM 'modules/vm.bicep' = [
  for (vm, i) in vms: {
    scope: resourceGroup(vm.rgName)
    name: vm.name
    params: {
      availabilitySetName: vm.availabilitySetName
      computerName: contains(vm, 'computerName') ? vm.computerName : vm.name
      extensions: vm.extensions
      imageReference: vm.imageReference
      location: location
      name: vm.name
      networkInterfaces: vm.networkInterfaces
      osDiskSizeGB: vm.osDiskSizeGB
      plan: vm.plan
      vmSize: vm.vmSize
      vnetName: vnetM.outputs.name
      vnetRg: rg.name
      deployIIS: vm.deployIIS
      tags: union(config.tags, vm.tags)
    }
  }
]
