targetScope = 'tenant'

param config object = {
  product: 'governance'
  location: 'we'
  tags: {
    Product: 'Governance'
    Environment: 'Production'
    CostCenter: '9100'
  }
}
param environment string
param location string = deployment().location

var mgRootId = '123-f5b83846ddee'
var platformSubscription = {
  name: 'sub-platform-prod-01'
  id: '123-04523f31826d'
}
var amplRgName = 'rg-platform-resourcemanager-prod-we-01'
var dnsRgName = 'rg-platform-dns-prod-we-01'

var vnetId = resourceId(
  platformSubscription.id,
  'rg-platform-hub-prod-we-01',
  'Microsoft.Network/virtualNetworks',
  'vnet-platform-hub-prod-we-01'
)
var subnetId = resourceId(
  platformSubscription.id,
  'rg-platform-hub-prod-we-01',
  'Microsoft.Network/virtualNetworks/subnets',
  'vnet-platform-hub-prod-we-01',
  'snet-pep'
)

module rgAmpl 'modules/rg.bicep' = {
  scope: subscription(platformSubscription.id)
  name: 'ampl_rg'
  params: {
    name: amplRgName
    location: location
    tags: config.tags
  }
}

module pdnsz_ampl 'modules/pdnsz.bicep' = {
  name: 'ampl_pdnsz'
  scope: resourceGroup(platformSubscription.id, dnsRgName)
  params: {
    name: 'privatelink.azure.com'
    vnetName: 'vnet-platform-hub-prod-we-01'
    vnetId: vnetId
  }
}

module amplM 'modules/ampl.bicep' = {
  scope: resourceGroup(platformSubscription.id, amplRgName)
  name: 'ampl'
  dependsOn: [
    rgAmpl
  ]
  params: {
    name: toLower('ampl-${config.product}-resourcemanager-${environment}-${config.location}-01')
    location: location
    pdnszId: pdnsz_ampl.outputs.id
    snetId: subnetId
  }
}

resource mgTenantRoot 'Microsoft.Management/managementGroups@2023-04-01' existing = {
  name: mgRootId
}

module ampl 'modules/ampl_assosiation.bicep' = {
  scope: mgTenantRoot
  name: 'ampl_assosiation'
  params: {
    amplId: amplM.outputs.id
  }
}
