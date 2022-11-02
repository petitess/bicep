targetScope = 'resourceGroup'

param affix string
param location string

var tags = resourceGroup().tags
//Put Container Config string below. You find it on Server container in Google Tag Manager
var containerconfig = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

resource plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'app-gtm-${affix}-plan-01'
  location: location
  tags: union(tags, {
    Type: 'Preview server'
  })
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true
    zoneRedundant: false
  }
}

resource app 'Microsoft.Web/sites@2022-03-01' = {
  name: 'app-gtm-${affix}-01' 
  location: location
  tags: union(tags, {
    Type: 'Preview server'
  })
  properties: {
    serverFarmId: plan.id
    clientAffinityEnabled: false
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|gcr.io/cloud-tagging-10302018/gtm-cloud-image:stable'
      appCommandLine: ''
      alwaysOn:  false
      ftpsState: 'FtpsOnly'
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://index.docker.io'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: ''
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: null
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'RUN_AS_PREVIEW_SERVER'
          value: 'true'
        }
        {
          name: 'CONTAINER_CONFIG'
          value: containerconfig
        }
      ]
    }
  }
}

resource appconfig 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'web'
  parent: app
  properties: {
    healthCheckPath: '/healthz'
    minTlsVersion: '1.2'
  }
}

resource plan2 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'app-gtm-${affix}-plan-02'
  location: location
  tags: union(tags, {
    Type: 'Tagging server'
  })
  kind: 'linux'
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  properties: {
    reserved: true
    zoneRedundant: false

  }
}

resource app2 'Microsoft.Web/sites@2022-03-01' = {
  name: 'app-gtm-${affix}-02' 
  location: location
  tags: union(tags, {
    Type: 'Tagging server'
  })
  properties: {
    serverFarmId: plan2.id
    clientAffinityEnabled: false
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|gcr.io/cloud-tagging-10302018/gtm-cloud-image:stable'
      appCommandLine: ''
      alwaysOn:  true
      ftpsState: 'FtpsOnly'
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://index.docker.io'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: ''
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: null
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'PREVIEW_SERVER_URL'
          value: 'https://${app.name}.azurewebsites.net'
        }
        {
          name: 'CONTAINER_CONFIG'
          value: containerconfig
        }
      ]
    }
  }
}

resource appconfig2 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'web'
  parent: app2
  properties: {
    healthCheckPath: '/healthz'
    minTlsVersion: '1.2'
  }
}

resource scaling 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: '${app2.name}-autoscale01'
  location: location
  properties: {
    name: '${app2.name}-autoscale01'
    enabled: true
    targetResourceUri: plan2.id
    predictiveAutoscalePolicy: {
      scaleMode: 'Disabled'
    }
    profiles:  [
      {
        name: 'Condition01'
        capacity: {
          default: '1'
          maximum: '5'
          minimum: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: resourceId('Microsoft.Web/serverfarms', plan2.name)
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 70
              dimensions: []
              dividePerInstance: false
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: resourceId('Microsoft.Web/serverfarms', plan2.name)
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 70
              dimensions: []
              dividePerInstance: false
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
        ]
      }
    ]
  }
}

output serverfarmsid string = plan.id
output serverfarmsname string = plan.name

