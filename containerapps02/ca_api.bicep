param caName string
param location string = resourceGroup().location
param envId string
param workloadProfileName 'Consumption' | 'GPU_WORKLOAD' = 'GPU_WORKLOAD'

resource ca 'Microsoft.App/containerApps@2025-10-02-preview' = {
  name: caName
  location: location
  kind: 'containerapps'
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: envId
    environmentId: envId
    workloadProfileName: workloadProfileName
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 11434
        exposedPort: 0
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
      }
      identitySettings: []
      maxInactiveRevisions: 100
    }
    template: {
      containers: [
        {
          image: 'docker.io/ollama/ollama:latest'
          imageType: 'ContainerImage'
          name: caName
          env: [
            {
              name: 'OLLAMA_HOST'
              value: '0.0.0.0'
            }
          ]
          resources: {
            cpu: json('8')
            memory: '56Gi'
          }
          volumeMounts: [
            {
              volumeName: 'ollama-data'
              mountPath: '/root/.ollama'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 10
        cooldownPeriod: 600
        pollingInterval: 30
        rules: [
          {
            name: 'http-scaler'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
      volumes: [
        {
          name: 'ollama-data'
          storageType: 'AzureFile'
          storageName: 'ollama-data'
        }
      ]
    }
  }
}

output caId string = ca.id
output caUrl string = ca.properties.configuration.ingress.fqdn
