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
  'privatelink.azurewebsites.net'
]

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-hub-${prefix}-01'
  location: location
  tags: union(config.tags, {
    System: config.product
  })
}

resource rgAsp 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-asp-${prefix}-01'
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

resource rgFunc 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-func-${prefix}-01'
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

module logM 'modules/log.bicep' = {
  scope: rg
  name: 'log'
  params: {
    name: 'log-${prefix}-01'
  }
}

module appi 'modules/appi.bicep' = {
  scope: rg
  name: 'appi'
  params: {
    name: 'appi-${prefix}-01'
    logId: logM.outputs.id
  }
}

module aspLinuxM 'modules/asp.bicep' = {
  scope: rgAsp
  name: 'asp-linux'
  params: {
    kind: 'linux'
    name: 'asp-linux-${prefix}-01'
    sku: 'P0v3'
  }
}

module aspWinM 'modules/asp.bicep' = {
  scope: rgAsp
  name: 'asp-win'
  params: {
    kind: 'app'
    name: 'asp-windows-${prefix}-02'
    sku: 'P0v3'
  }
}

module stFuncLinux 'modules/st.bicep' = {
  scope: rgSt
  name: 'stfunc-linux'
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

module stFuncWin 'modules/st.bicep' = {
  scope: rgSt
  name: 'stfunc-windows'
  params: {
    name: 'stfunc${prefixSt}02'
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

module funcLinux 'modules/func.bicep' = {
  scope: rgFunc
  name: 'func-linux'
  params: {
    funcAppServicePlanId: aspLinuxM.outputs.id
    name: 'func-${prefix}-01'
    kind: 'functionapp,linux'
    snetOutboundId: subnet['snet-func-linux-outbound'].id
    appiConnectionString: appi.outputs.connectionString
    defaultEndpointsProtocol: stFuncLinux.outputs.defaultEndpointsProtocol
    snetPepId: subnet['snet-pep'].id
    rgDns: rg.name
  }
}

module funcWin 'modules/func.bicep' = {
  scope: rgFunc
  name: 'func-windows'
  params: {
    funcAppServicePlanId: aspWinM.outputs.id
    name: 'func-${prefix}-02'
    kind: 'functionapp'
    snetOutboundId: subnet['snet-func-windows-outbound'].id
    appiConnectionString: appi.outputs.connectionString
    defaultEndpointsProtocol: stFuncWin.outputs.defaultEndpointsProtocol
    snetPepId: subnet['snet-pep'].id
    rgDns: rg.name
  }
}
