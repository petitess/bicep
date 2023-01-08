targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param enabled bool
param log string
param ag string

resource alert 'Microsoft.Insights/scheduledQueryRules@2022-06-15' = {
  name: '${name}_No_Heartbeat'
  location: location
  tags: tags
  properties: {
    displayName: '${name}_No_Heartbeat'
    description: 'No heatbeat reported to log analytics last hour'
    severity: 2
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
