param caName string
param location string = resourceGroup().location
param envId string
param apiUrl string
param workloadProfileName 'Consumption' | 'GPU_WORKLOAD' = 'Consumption'

resource caName_resource 'Microsoft.App/containerApps@2025-10-02-preview' = {
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
        targetPort: 8080
        exposedPort: 0
        transport: 'Auto'
        additionalPortMappings: []
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
        stickySessions: {
          affinity: 'none'
        }
      }
      identitySettings: []
      maxInactiveRevisions: 100
    }
    template: {
      containers: [
        {
          image: 'ghcr.io/open-webui/open-webui:main'
          imageType: 'ContainerImage'
          name: caName
          env: [
            {
              name: 'OLLAMA_BASE_URL'
              value: 'https://${apiUrl}'
            }
            {
              name: 'WEBUI_SECRET_KEY'
              value: 'z'
            }
          ]
          resources: {
            cpu: json('4')
            memory: '8Gi'
          }
          volumeMounts: [
            // When you change data folder you get this error.
            // The TargetPort 8080 does not match the listening port 32134. 1/1 Container crashing: ca-ollama-gui-czr-dev-01
            // {
            //   volumeName: 'openwebui-data'
            //   mountPath: '/app/backend/data'
            // }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 10
        cooldownPeriod: 600
        pollingInterval: 30
      }
      volumes: [
        {
          name: 'openwebui-data'
          storageType: 'AzureFile'
          storageName: 'openwebui-data'
        }
      ]
    }
  }
}
