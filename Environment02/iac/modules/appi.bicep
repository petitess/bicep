targetScope = 'resourceGroup'

param name string
param location string
param WorkspaceResourceId string
param webtests array
param actionGroupId string
param time string = dateTimeAdd(utcNow(), 'PT1M', 'yyyy-MM-ddTHH:mm:ss')

var tags = resourceGroup().tags

resource appi 'Microsoft.Insights/components@2020-02-02' = {
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
    RetentionInDays: 30
    WorkspaceResourceId: WorkspaceResourceId
  }
}

resource webtest 'Microsoft.Insights/webtests@2022-06-15' = [
  for webtest in webtests: {
    name: 'avail-${webtest.name}'
    location: location
    dependsOn: [
      appi
    ]
    tags: {
      'hidden-link:${resourceId('Microsoft.Insights/components', name)}': 'Resource'
    }
    kind: 'standard'
    properties: {
      Name: webtest.name
      SyntheticMonitorId: '${webtest.name}-id'
      Description: '${webtest.name} - ${webtest.description}'
      Enabled: false
      Frequency: 300
      Kind: 'standard'
      RetryEnabled: true
      Locations: [
        {
          Id: 'emea-nl-ams-azr'
        }
        // {
        //   Id: 'emea-se-sto-edge'
        // }
        // {
        //   Id: 'emea-gb-db3-azr'
        // }
        // {
        //   Id: 'emea-ru-msa-edge'
        // }
        // {
        //   Id: 'latam-br-gru-edge'
        // }
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
        SSLCheck: true
        SSLCertRemainingLifetimeCheck: 7
      }
    }
  }
]

resource alerts 'Microsoft.Insights/metricAlerts@2018-03-01' = [
  for (alert, i) in webtests: {
    name: 'avail-${alert.name}'
    location: 'global'
    tags: {
      URL: alert.url
    }
    properties: {
      description: '${alert.url} - ${alert.description}'
      criteria: {
        'odata.type': 'Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria'
        componentId: appi.id
        failedLocationCount: 4
        webTestId: webtest[i].id
      }
      enabled: alert.enabled
      evaluationFrequency: 'PT1M'
      scopes: [
        webtest[i].id
        appi.id
      ]
      severity: 1
      windowSize: 'PT3M'
      actions: [
        {
          actionGroupId: actionGroupId
        }
      ]
    }
  }
]

resource supressionWebtest 'Microsoft.AlertsManagement/actionRules@2023-05-01-preview' = [
  for (alert, i) in webtests: {
    name: 'disable-${alert.name}'
    location: 'global'
    tags: tags
    properties: {
      enabled: true
      description: 'Disables ${alert.name} outside working hours'
      actions: [
        {
          actionType: 'RemoveAllActionGroups'
        }
      ]
      scopes: [
        subscription().id
      ]
      schedule: {
        timeZone: 'W. Europe Standard Time'
        effectiveFrom: time
        recurrences: [
          {
            recurrenceType: 'Daily'
            startTime: '18:00:00'
            endTime: '06:30:00'
          }
        ]
      }
      conditions: [
        {
          field: 'AlertRuleName'
          operator: 'Equals'
          values: [
            'avail-${alert.name}'
          ]
        }
      ]
    }
  }
]

output id string = appi.id
output ConnectionString string = appi.properties.ConnectionString
