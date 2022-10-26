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
  name: replace(webtest, 'https://', 'avail-')
  location: location
  dependsOn: [
    appinsight
  ]
  tags: {
    'hidden-link:${resourceId('Microsoft.Insights/components', name)}': 'Resource'
  }
  kind:  'ping'
  properties: {
    Name: webtest
    SyntheticMonitorId: '${webtest}-id'
    Description: '${webtest} - GET request'
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
    ]
    Request: {
      RequestUrl: webtest
      Headers: null
      HttpVerb: 'GET'
      RequestBody: null
      ParseDependentRequests: false
      FollowRedirects: null
    }
  }
}]

resource alerts 'Microsoft.Insights/metricAlerts@2018-03-01' =[for (alert, i) in webtests: {
  name: replace(alert, 'https://', 'avail-')
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
      appinsight.id
      webtest[i].id
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

