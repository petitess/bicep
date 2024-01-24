targetScope = 'subscription'

param config object
param environment string
param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location

var constants = loadJsonContent('constants.json')

var prefixSpoke = toLower('${config.product}-spoke-${environment}-${config.location}')
var unique = take(uniqueString(subscription().subscriptionId), 3)
var prefixRg = toLower('${config.product}-${config.system}-common-${environment}-${config.location}')
var prefixScoped = toLower('${config.product}-${unique}-${environment}-${config.location}')
var prefixShort = toLower('${config.shortProduct}-${config.shortSystem}-${unique}-${environment}')
var prefixMonitor = toLower('${config.product}-monitor-${environment}-${config.location}')
var snet = toObject(vnet.outputs.subnets, subnet => subnet.name)
var secrets = []
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

var domains = [
  'privatelink.vaultcore.azure.net'
  'privatelink${az.environment().suffixes.sqlServerHostname}'
  'privatelink.blob.${az.environment().suffixes.storage}'
  'privatelink.search.windows.net'
  ]

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${prefixRg}-01'
  location: location
  tags: union(config.tags, {
      System: 'Common'
    })
}

resource rgSpoke 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${prefixSpoke}-01'
  location: location
  tags: union(config.tags, {
      System: 'Spoke'
    })
}

resource rgDns 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: toLower('rg-${config.product}-dns-${environment}-${config.location}-01')
  location: location
  tags: union(config.tags, {
      System: 'DNS'
    })
}

resource rgMonitor 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${prefixMonitor}-01'
  location: location
  tags: union(config.tags, {
      System: 'Monitor'
    })
}

module vnet 'modules/vnet.bicep' = {
  name: 'vnet_${timestamp}'
  scope: rgSpoke
  params: {
    prefix: prefixSpoke
    location: location
    addressPrefixes: config.vnet.addressPrefixes
    subnets: config.vnet.subnets
    allowedSubnets: allowedSubnets[environment]
  }
}

module pdnsz 'modules/pdnsz.bicep' = [for (domain, i) in domains: {
  name: 'pdnsz${i}_${timestamp}'
  scope: rgDns
  params: {
    name: domain
    vnetName: vnet.outputs.name
    vnetId: vnet.outputs.id
  }
}]

module log 'modules/log.bicep' = {
  scope: rgMonitor
  name: 'log_${timestamp}'
  params: {
    name: 'log-${prefixMonitor}-01'
    location: location
  }
}

module appi 'modules/appi.bicep' = {
  scope: rg
  name: 'appi_${timestamp}'
  params: {
    name: 'appi-${prefixScoped}-01'
    location: location
    logId: log.outputs.id
  }
}


module kv 'modules/kv.bicep' = {
  scope: rg
  name: 'kv_${timestamp}'
  params: {
    name: 'kv-${prefixShort}-01'
    location: location
    environment: environment
    subnetId: snet['snet-standards-std-common-inbound'].id
    pdnszRg: rgDns.name
    secrets: secrets
  }
}

module rbacId 'modules/rbac.bicep' = {
  name: 'rbac_Id_${timestamp}'
  scope: rg
  params: {
    principalId: srch.outputs.principalId
    roles: [
      'Key Vault Secrets User'
    ]
    principalType: 'ServicePrincipal'
    system: ''
  }
}

module sql 'modules/sql.bicep' = {
  scope: rg
  name: 'sql_${timestamp}'
  params: {
    location: location
    name: config.database.servername
    dbName: config.database.dbname
    subneId: snet['snet-standards-std-common-inbound'].id
    pdnszRg: rgDns.name
    db_skuName: config.database.sku.name
    db_skuTier: config.database.sku.tier
    db_skuCapacity: config.database.sku.capacity
    privateEndpointName: '${config.product}-${config.system}-sql-${environment}-${config.location}-01'
  }
}

module st 'modules/st.bicep' = {
  scope: rg
  name: 'st_${timestamp}'
  params: {
    storageAccountName: 'st${config.shortProduct}${config.shortSystem}${unique}${environment}${config.location}01'
    location: location
    keyvaultname: kv.outputs.name
    connectionBlobContainer: constants.connectionBlobContainer
    pdnszRg: rgDns.name
    subnetId: snet['snet-standards-std-common-inbound'].id
  }
}

module srch 'modules/srch.bicep' = {
  scope: rg
  name: 'srch_${timestamp}'
  params: {
    name: 'srch-${prefixScoped}-01'
    location: location
    environment: environment
    skuName: config.searchService.skuName
    pdnszRg: rgDns.name
    subnetId: snet['snet-standards-std-common-inbound'].id
    sqlResourceId: sql.outputs.sqlServerId
  }
}

output sqlServerId string = sql.outputs.sqlServerId
