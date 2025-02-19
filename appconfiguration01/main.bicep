targetScope = 'subscription'

param MyIp string
output IP string = MyIp
param env string
param location string
param tags object
param vnet object
param timestamp int = dateTimeToEpoch(utcNow())

var domains = [
  'privatelink.azconfig.io'
  'privatelink.azure.com'
]
param featureFlags array
var affix = toLower('${tags.Application}-${env}')
func name(prefix string, instance string) string => '${prefix}-${affix}-${instance}'

var snet = toObject(vnetE.properties.subnets, subnet => subnet.name)

resource vnetE 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: name('vnet', '01')
  scope: resourceGroup(name('rg-vnet', '01'))
  dependsOn: [
    vnetM
    rg
  ]
}

resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  location: location
  tags: tags
  name: name('rg-vnet', '01')
}

resource rgDns 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  location: location
  tags: tags
  name: name('rg-dns', '01')
}

resource rgampl 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  location: location
  tags: tags
  name: name('rg-ampl', '01')
}

module vnetM 'vnet.bicep' = {
  scope: rg
  name: 'vnet-${timestamp}'
  params: {
    addressPrefixes: vnet.addressPrefixes
    name: name('vnet', '01')
    location: location
    subnets: vnet.subnets
  }
}

module appcs 'appcs.bicep' = {
  scope: rg
  name: 'appcs'
  params: {
    name: name('appcszz', '01')
    location: location
    snetId: snet['snet-pep'].id
    pdnszRg: rgDns.name
    featureFlags: featureFlags
  }
}

module pdnszM 'pdnsz.bicep' = [
  for (domain, i) in domains: {
    name: 'pdnsz-${split(domain, '.')[1]}'
    scope: rgDns
    params: {
      name: domain
      vnetName: vnetM.outputs.name
      vnetId: vnetM.outputs.id
    }
  }
]

module amplM 'ampl.bicep' = {
  scope: rgampl
  name: 'ampl'
  params: {
    name: name('ampl', '01')
    location: location
    pdnszRg: rgDns.name
    snetId: snet['snet-pep'].id
  }
}

output amplId string = amplM.outputs.amplId
output tenantId string = tenant().tenantId
