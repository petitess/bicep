targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param enabled bool
param log string
param ag string

resource alert 'microsoft.insights/scheduledqueryrules@2021-08-01' = {
  name: '${name}_No_Heartbeat'
  location: location
  tags: tags
  properties: {
    displayName: '${name}_No_Heartbeat'
    description: 'No heatbeat reported to log analytics last hour'
    severity: 2
    enabled: enabled
    evaluationFrequency: 'PT1H'
    scopes: [
      log
    ]
    windowSize: 'PT2H'
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
