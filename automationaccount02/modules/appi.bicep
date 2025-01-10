targetScope = 'resourceGroup'

param name string
param location string
param WorkspaceResourceId string
param webtests array
param actionGroupId string
param actionGroupRestartGtm string

var tags = resourceGroup().tags
var actionGroupGtm = [
  {
    actionGroupId: actionGroupRestartGtm
  }
]
resource appinsight 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    Request_Source: 'rest'
    RetentionInDays: 90
    WorkspaceResourceId: WorkspaceResourceId
  }
}

resource webtest 'Microsoft.Insights/webtests@2022-06-15' = [
  for webtest in webtests: {
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
      Kind: 'standard'
      RetryEnabled: true
      Locations: [
        {
          Id: 'emea-nl-ams-azr'
        }
        {
          Id: 'emea-se-sto-edge'
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
  }
]

resource alerts 'Microsoft.Insights/metricAlerts@2018-03-01' = [
  for (alert, i) in webtests: {
    name: 'avail-${alert.name}'
    location: 'global'
    properties: {
      description: alert.url
      criteria: {
        'odata.type': 'Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria'
        componentId: appinsight.id
        failedLocationCount: 2
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
      autoMitigate: true
      actions: contains(alert, 'actionGroupGtm') && alert.actionGroupGtm
        ? concat(
            [
              {
                actionGroupId: actionGroupId
              }
            ],
            actionGroupGtm
          )
        : [
            {
              actionGroupId: actionGroupId
            }
          ]
    }
  }
]
