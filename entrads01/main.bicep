targetScope = 'subscription'

param env string
param tags object
param location string
param vnet object
param entrads object

var affix = toLower('${tags.Application}-${env}')
func name(prefix string, instance string) string => '${prefix}-${affix}-${instance}'

var snet = toObject(vnetE.properties.subnets, subnet => subnet.name)

resource vnetE 'Microsoft.Network/virtualNetworks@2024-03-01' existing = {
  name: name('vnet', '01')
  scope: resourceGroup(name('rg-vnet', '01'))
  dependsOn: [
    vnetM
    rg
  ]
}

resource rg 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  location: location
  tags: tags
  name: name('rg-vnet', '01')
}

module vnetM 'vnet.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    addressPrefixes: vnet.addressPrefixes
    dnsServers: vnet.dnsServers
    location: location
    name: name('vnet', '01')
    natGateway: vnet.natGateway
    peerings: vnet.peerings
    subnets: vnet.subnets
  }
}

resource rgEntrads 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: name('rg-entrads', '01')
  location: location
  tags: tags
}

module entradsM 'entrads.bicep' = {
  scope: rgEntrads
  name: 'entrads'
  params: {
    subnetId: snet['snet-entrads'].id
    location: location
    name: name('entrads', '01')
    domainName: entrads.domainname
    sku: entrads.sku
    notificationSettings: entrads.notificationSettings
  }
}
