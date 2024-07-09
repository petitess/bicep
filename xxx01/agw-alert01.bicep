param location string
param agw string
param tags object
param actionGroupId string

// resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' existing = {
//   name: 'B3 Support Email Alert'
// }

resource alert 'Microsoft.Insights/scheduledQueryRules@2024-01-01-preview' = {
  name: 'alert-${agw}-backendHealth'
  location: location
  tags: tags
  properties: {
    enabled: true
    displayName: 'alert-${agw}-backendHealth'
    description: 'alert-${agw}-backendHealth'
    scopes: [
      subscription().id
    ]
    actions: {
      actionGroups: [
        actionGroupId
      ]
    }
    criteria: {
      allOf: [
        {
          query: '''
AzureMetrics
| where ResourceProvider == "MICROSOFT.NETWORK"
| where ResourceId contains "APPLICATIONGATEWAYS"
| where MetricName == "UnhealthyHostCount" // This metric indicates unhealthy hosts
| summarize UnhealthyHosts = max(Maximum) by bin(TimeGenerated, 5m), ResourceId
| where UnhealthyHosts > 0 // Filter out entries where UnhealthyHosts is zero
| project TimeGenerated, ResourceId, UnhealthyHosts
| order by TimeGenerated desc
          '''
          threshold: 0
          operator: 'GreaterThan'
          timeAggregation: 'Count'
          failingPeriods: {
            minFailingPeriodsToAlert: 1
            numberOfEvaluationPeriods: 1
          }
        }
      ]
    }
    evaluationFrequency: 'PT15M'
    severity: 2
    windowSize: 'PT2H'
  }
}
