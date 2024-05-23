targetScope = 'subscription'

param config object
param environment string
param location string = deployment().location
param vnet object

var prefix = toLower('${config.product}-${environment}-${config.location}')
var prefixSt = toLower('${config.product}${environment}${config.location}')

var subnet = toObject(
  reference(
    resourceId(subscription().subscriptionId, rg.name, 'Microsoft.Network/virtualNetworks', 'vnet-${prefix}-01'),
    '2023-11-01'
  ).subnets,
  subnet => subnet.name
)

output sub string = subnet['snet-pep'].id
var myIp = '188.150.1.1'

var domains = [
  'privatelink.blob.${az.environment().suffixes.storage}'
  'privatelink.file.${az.environment().suffixes.storage}'
]

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-hub-${prefix}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

resource rgSt 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-st-${prefix}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

resource rgBVault 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-bvault-${prefix}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

module vnetM 'modules/vnet.bicep' = {
  name: 'vnet'
  scope: rg
  params: {
    prefix: prefix
    location: location
    addressPrefixes: vnet.addressPrefixes
    subnets: vnet.subnets
    flowLogsEnabled: false
  }
}

module pdnsz 'modules/pdnsz.bicep' = [
  for (domain, i) in domains: {
    name: 'pdnsz_${split(domain, '.')[1]}'
    scope: rg
    params: {
      name: domain
      vnetName: vnetM.outputs.name
      vnetId: vnetM.outputs.id
    }
  }
]

module st 'modules/st.bicep' = {
  scope: rgSt
  name: 'st'
  params: {
    name: 'stfunc${prefixSt}01'
    location: location
    dnsRgName: rg.name
    snetId: subnet['snet-pep'].id
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      ipRules: [
        {
          value: myIp
        }
      ]
      defaultAction: 'deny'
    }
    privateEndpoints: [
      'blob'
      'file'
    ]
  }
}

module bvaultM 'modules/bvault.bicep' = {
  scope: rgBVault
  name: 'bvault'
  params: {
    name: 'bvault-${prefix}-01'
  }
}
