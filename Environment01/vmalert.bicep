targetScope = 'resourceGroup'

param name string
param location string
param enabled bool
param log string
param vmId string
param ag string

var tags = resourceGroup().tags

resource alert 'Microsoft.Insights/scheduledQueryRules@2023-03-15-preview' = {
  name: '${name}_No_Heartbeat'
  location: location
  tags: tags
  properties: {
    displayName: '${name}_No_Heartbeat'
    description: 'No heatbeat reported to log analytics'
    severity: 0
    enabled: enabled
    evaluationFrequency: 'PT5M'
    scopes: [
      log
    ]
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          query: 'let varComputer = "${name}";\nHeartbeat \n| where Computer contains varComputer\n'
          timeAggregation: 'Count'
          operator: 'LessThan'
          threshold: 1
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    actions: {
      actionGroups: [
        ag
      ]
    }
    autoMitigate: true
  }
}

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' =  {
  name: '${name}_cpu'
  location: 'global'
  tags: tags
  properties: {
    description: 'CPU usage'
    severity: 3
    enabled: true
    scopes: [
      vmId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: '1st criterion'
          metricNamespace: 'Microsoft.Compute/virtualMachines'
          metricName: 'Percentage CPU'
          operator: 'GreaterThan'
          threshold: 90 
          timeAggregation: 'Minimum'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: [
      {
        actionGroupId: ag
      }
    ]
  }
}


