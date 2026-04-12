targetScope = 'subscription'

param timestamp int = dateTimeToEpoch(utcNow())
param location string = deployment().location
param tags object
param env 'dev' | 'prod'
param apim {
  initialDeploy: bool
  skuName: resourceInput<'Microsoft.ApiManagement/service@2025-03-01-preview'>.sku.name
  capacity: int
  publisherName: string
  publisherEmail: string
  customProperties: resourceInput<'Microsoft.ApiManagement/service@2025-03-01-preview'>.properties.customProperties
  virtualNetworkType: resourceInput<'Microsoft.ApiManagement/service@2025-03-01-preview'>.properties.virtualNetworkType
  sslCertificates: ('SecretName' | 'CertName')[]
  @description('Private IP address for private endpoint')
  ipAddress: string
  @description('Custom domain for API service. Requires CNAME verification.')
  hostnameApi: string
  @description('Custom domain for Developer Portal. Requires CNAME verification.')
  hostnamePortal: string
  @description('Custom domain for API Management(v1).')
  hostnameManagement: string?
}?

param apis ({
  name: string
  @description('Unique API URL suffix')
  path: string
  description: string?
  @description('XML content')
  roles: string
  displayName: string
  subscriptionRequired: bool
  isCurrent: bool
  @description('Absolute URL of the backend service implementing this API. Must end with /')
  serviceUrl: string?
  @description('XML content')
  policyContent: string?
  contact: {
    name: string
    email: string
  }?
  operations: {
    name: string
    displayName: string
    method: string
    @description('Endpoint URL. Must end with /. e.g. /getItem')
    urlTemplate: string
    description: string
    @description('XML content')
    policyContent: string
  }[]?
  swaggerPath: string?
  @description('For Developer portal')
  addProduct: bool?
  @description('For Developer portal')
  productState: 'published' | 'notPublished'?
  @description('For Developer portal')
  productVisiableForGuests: bool?
  @description('For Developer portal')
  addGroup: bool?
})[]

var afdId = {
  dev: '8463304d-f7a3-4ce1-86a7-d02accdf4cc3'
  prod: '9039fee3-ea87-489d-97e7-0b417953aab1'
}
var prefix = toLower('sys-${env}')

func name(res string, instance string) string => '${res}-${prefix}-${instance}'

resource rgVnetAppE 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
  name: 'rg-vnet-sys-${env}-01'
}

resource vnetE 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  scope: rgVnetAppE
  name: 'vnet-sys-${env}-01'

  resource snetPepApp 'subnets' existing = {
    name: 'snet-pep'
  }
}

resource rgApim 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-apim', '01')
  location: location
  tags: union(tags, {
    System: 'APIM'
  })
}

module apimM 'modules/apim.bicep' = {
  name: 'apim-${timestamp}'
  scope: rgApim
  params: {
    initialDeploy: apim.?initialDeploy
    name: 'apim-${env}-abcd-01'
    location: location
    tags: tags
    skuName: apim.?skuName
    skuCapacity: apim.?capacity
    publisherName: apim.?publisherName
    publisherEmail: apim.?publisherEmail
    virtualNetworkType: apim.?virtualNetworkType
    vnetName: vnetE.name
    vnetResourceGroup: rgVnetAppE.name
    snetName: 'snet-apim'
    customProperties: apim.?customProperties
    kvName: 'kvcertabc${env}01'
    hostnameApi: apim.?hostnameApi
    hostnamePortal: apim.?hostnamePortal
    hostnameManagement: apim.?hostnameManagement
    workspaceId: monitor.outputs.logId
    appiId: monitor.outputs.appiId
    appiName: monitor.outputs.appiName
    instrumentationKey: monitor.outputs.instrumentationKey
    env: env
    sslCertificates: apim.?sslCertificates ?? []
    afdId: afdId[env]
    dnsRg: rgVnetAppE.name
    ipAddress: apim.?ipAddress
    snetPep: vnetE::snetPepApp.id
  }
}

module monitor 'modules/monitor.bicep' = {
  scope: rgApim
  name: 'monitor'
  params: {
    location: location
    env: env
  }
}

module apiM 'modules/api.bicep' = [
  for api in apis: {
    scope: rgApim
    name: '${api.name}-${timestamp}'
    dependsOn: [
      apimM
    ]
    params: {
      apimName: 'apim-${env}-abcd-01'
      name: api.name
      path: api.path
      roles: api.roles
      displayName: api.displayName
      description: api.?description
      subscriptionRequired: api.subscriptionRequired
      isCurrent: api.isCurrent
      serviceUrl: api.?serviceUrl
      policyContent: api.?policyContent
      contact: api.?contact
      operations: api.?operations
      swaggerPath: api.?swaggerPath
      addProduct: api.?addProduct
      productState: api.?productState
      productVisiableForGuests: api.?productVisiableForGuests
      addGroup: api.?addGroup
    }
  }
]
