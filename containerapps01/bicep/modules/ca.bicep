param name string
param location string = resourceGroup().location
param tags object = resourceGroup().tags
param caeId string
param acrName string
param acrRepo string
param acrRepoVer string
param acrAccessKey string

resource name_resource 'Microsoft.App/containerApps@2024-03-01' = {
  name: name
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  tags: tags
  properties: {
    environmentId: caeId
    configuration: {
      secrets: [
        {
          name: 'secret01'
          value: acrAccessKey
        }
      ]
      registries: [
        {
          server: '${acrName}.azurecr.io'
          username: acrName
          passwordSecretRef: 'secret01'
        }
      ]
      activeRevisionsMode: 'Single'
      ingress: {
        allowInsecure: false
        external: true
        stickySessions: {
          affinity: 'sticky'
        }
        transport: 'auto'
      }
    }
    template: {
      containers: [
        {
          name: name
          image: '${acrName}.azurecr.io/${acrRepo}:${acrRepoVer}'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
      }
    }
    workloadProfileName: 'Consumption'
  }
}
