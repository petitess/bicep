targetScope = 'resourceGroup'

param name string
param location string 
param WorkspaceResourceId string
param webtests array

var tags = resourceGroup().tags

resource appinsight 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery:  'Enabled'
    Request_Source: 'rest'
    RetentionInDays: 90
    WorkspaceResourceId: WorkspaceResourceId
  }
}

resource webtest 'Microsoft.Insights/webtests@2022-06-15' = [for webtest in webtests: {
  name: 'avail-${webtest.name}'
  location: location
  dependsOn: [
    appinsight
  ]
  tags: {
    'hidden-link:${resourceId('Microsoft.Insights/components', name)}': 'Resource'
  }
  kind: 'standard'
  properties: {
    Name: webtest.name
    SyntheticMonitorId: '${webtest.name}-id'
    Description: '${webtest.name} - GET request'
    Enabled: true
    Frequency: 180
    Kind:  'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'emea-nl-ams-azr'
      }
      {
        Id: 'emea-se-sto-edge'
      }
      {
        Id: 'emea-gb-db3-azr'
      }
      {
        Id: 'emea-ru-msa-edge'
      }
      {
        Id: 'emea-fr-pra-edge'
      }
    ]
    Request: {
      RequestUrl: webtest.url
      Headers: null
      HttpVerb: 'GET'
      RequestBody: null
      ParseDependentRequests: false
      FollowRedirects: null
    }
    ValidationRules: {
      ExpectedHttpStatusCode: 200
      SSLCheck: false
    }
  }
}]

resource alerts 'Microsoft.Insights/metricAlerts@2018-03-01' =[for (alert, i) in webtests: {
  name: 'avail-${alert.name}'
  location: 'global'
  properties: {
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria'
      componentId: appinsight.id
      failedLocationCount: 4
      webTestId: webtest[i].id
    }
    enabled: true
    evaluationFrequency: 'PT1M'
    scopes: [
      webtest[i].id
      appinsight.id
    ]
    severity: 1
    windowSize: 'PT5M'
    //Specify an action group to get notified
    // actions: [
    //   {
    //     actionGroupId:
    //   }
    // ]
  }
}]

