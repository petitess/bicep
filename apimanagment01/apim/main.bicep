targetScope = 'subscription'

param config { product: 'infra', location: 'we' | 'sc' }
param tags {
  Product: 'Common Infrastructure'
  Environment: 'Development' | 'Staging' | 'Production'
  CostCenter: '9100'
}
param environment 'dev' | 'stg' | 'prod'
param location string = deployment().location
param vnet object
param apim {
  initialDeploy: bool
  sku:
    | 'Basic'
    | 'Consumption'
    | 'Developer'
    | 'Isolated'
    | 'Premium'
    | 'Standard'
    | 'BasicV2'
    | 'StandardV2'
    | 'PremiumV2'
  capacity: int
  publisherName: string
  publisherEmail: string
  type: 'External' | 'Internal' | 'None'
  customProperties: { *: bool }
}
param apis array

var prefixApim = toLower('${config.product}-apim-${environment}-${config.location}')
var prefixSpoke = toLower('${config.product}-spoke-${environment}-${config.location}')
var prefixMonitor = toLower('${config.product}-monitor-${environment}-${config.location}')
var prefixCert = toLower('${config.product}-cert-${environment}-abc')
var snet = toObject(vnetE.properties.subnets, subnet => subnet.name)
var sslCertificates = [
  // 'abc-com'
]

var hostnameApi = 'api-${environment}.abc.se'
var hostnamePortal = 'portal-api-${environment}.abc.se'
var hostnameManagement = 'management-api-${environment}.abc.se'
var afdId = {
  dev: '1261204d-f7a3-4ce1-12a7-d12accdf4cc7'
  stg: 'a1271c03-12ad-419e-12d5-f339d5c0877b'
  prod: '1239fee3-ea12-129d-97e7-0b417953aab2'
}
var domains = [
  // 'privatelink.vaultcore.azure.net'
]

resource vnetE 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: 'vnet-${prefixSpoke}-01'
  scope: resourceGroup('rg-${prefixSpoke}-01')
  dependsOn: [
    rgSpoke
    vnetM
  ]
}

resource rgApim 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: 'rg-${prefixApim}-01'
  location: location
  tags: tags
}

resource rgMonitor 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: 'rg-${prefixMonitor}-01'
  location: location
  tags: tags
}

resource rgSpoke 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  location: location
  tags: tags
  name: 'rg-${prefixSpoke}-01'
}

module log 'modules/log.bicep' = {
  scope: rgMonitor
  name: 'log'
  params: {
    name: 'log-${prefixMonitor}-01'
    location: location
  }
}

module pdnszM 'modules/pdnsz.bicep' = [
  for (domain, i) in domains: {
    name: 'pdnsz-${split(domain, '.')[1]}'
    scope: rgSpoke
    params: {
      name: domain
      vnetName: vnetM.outputs.name
      vnetId: vnetM.outputs.id
    }
  }
]
module kvCert 'modules/kv.bicep' = {
  scope: rgSpoke
  name: 'kvCert'
  params: {
    name: 'kv-${prefixCert}-01'
    location: location
    defaultAction: 'Deny'
    enableRbac: false
    workspaceId: log.outputs.id
    pdnszRgName: rgSpoke.name
    snetPepId: snet['snet-pep'].id
    rbac: [
      {
        principalId: apimM.outputs.identityId.SystemAssigned
        role: 'Key Vault Certificate User'
      }
    ]
  }
}

module vnetM 'modules/vnet.bicep' = {
  scope: rgSpoke
  name: 'vnet'
  params: {
    addressPrefixes: vnet.addressPrefixes
    name: 'vnet-${prefixSpoke}-01'
    location: location
    subnets: vnet.subnets
  }
}

module apimM 'modules/apim.bicep' = if (environment != 'prod') {
  name: 'apim'
  scope: rgApim
  params: {
    initialDeploy: apim.initialDeploy
    name: 'apim-abc-${prefixApim}-01'
    location: location
    tags: tags
    skuName: apim.sku
    skuCapacity: apim.capacity
    publisherName: apim.publisherName
    publisherEmail: apim.publisherEmail
    virtualNetworkType: apim.type
    vnetName: vnetE.name
    vnetResourceGroup: rgSpoke.name
    snetName: snet['snet-apim'].name
    customProperties: apim.customProperties
    hostnameApi: hostnameApi
    hostnamePortal: hostnamePortal
    hostnameManagement: hostnameManagement
    keyVaultId: ''
    workspaceId: log.outputs.id
    appiId: appi.outputs.id
    appiName: appi.outputs.name
    instrumentationKey: appi.outputs.instrumentationKey
    prefixCert: prefixCert
    prefixSpoke: prefixSpoke
    sslCertificates: sslCertificates
    afdId: afdId[environment]
  }
}

module appi 'modules/appi.bicep' = {
  scope: rgApim
  name: 'appi'
  params: {
    location: location
    name: 'appi-${prefixApim}-01'
    WorkspaceResourceId: log.outputs.id
  }
}

module apiM 'modules/api.bicep' = [
  for api in apis: {
    scope: rgApim
    name: api.name
    dependsOn: [
      apimM
    ]
    params: {
      apimName: 'apim-abc-${prefixApim}-01'
      name: api.name
      path: api.path
      url: api.url
      swaggerPath: api.swaggerPath
      environment: environment
      roles: api.roles
      displayName: api.displayName
    }
  }
]
