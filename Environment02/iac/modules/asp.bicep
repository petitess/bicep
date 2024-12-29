param env string
param location string
param aspList ({ aspName: string, skuName: string, OS: ('Linux' | 'Windows') })[]
param tags object = resourceGroup().tags

resource asp 'Microsoft.Web/serverfarms@2024-04-01' = [
  for plan in aspList: {
    name: plan.aspName
    location: location
    tags: tags
    sku: {
      name: plan.skuName
    }
    kind: 'app'
    properties: {
      perSiteScaling: false
      elasticScaleEnabled: false
      maximumElasticWorkerCount: 1
      isSpot: false
      reserved: plan.OS == 'Linux' ? true : false
      isXenon: false
      hyperV: false
      targetWorkerCount: 0
      targetWorkerSizeId: 0
      zoneRedundant: false
    }
  }
]

resource cert01 'Microsoft.Web/certificates@2024-04-01' = if (false) {
  name: 'cert-asp-${env}-01'
  location: location
  tags: tags
  properties: {
    keyVaultId: ''
    keyVaultSecretName: ''
  }
}

//output thumbprint01 string = cert01.properties.thumbprint
