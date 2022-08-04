targetScope = 'resourceGroup'

param virtualMachines array
param actionGroup string
param location string
param workspaceId string

var tags = resourceGroup().tags

resource heartbeat 'Microsoft.Insights/scheduledQueryRules@2021-08-01' = [for vm in virtualMachines: if(vm.VMalerts) {
  name: '${vm.name}_no_heartbeat'
  location: location
  tags: tags
  properties: {
    enabled: vm.VMalerts
    displayName:'${vm.name}_no_heartbeat'
    description: 'No heatbeat reported to log analytics'
    scopes: [
      workspaceId
    ]
    actions: {
      actionGroups: [
        actionGroup
      ]
    }
    criteria: {
      allOf: [
        {
          query: 'let varComputer = "${vm.name}";\nHeartbeat \n| where Computer contains varComputer\n'
          threshold: 1
          operator: 'LessThan'
          timeAggregation: 'Count'
          failingPeriods: {
            minFailingPeriodsToAlert: 1
            numberOfEvaluationPeriods: 1
          }
        }
      ]
    }
    evaluationFrequency: 'PT1M'
    severity: 2
    windowSize: 'PT1M'
    autoMitigate: true
  }
}]

resource heartbeat2 'Microsoft.Insights/scheduledQueryRules@2021-08-01' = {
  name: 'VM_failed_login'
  location: location
  tags: tags
  properties: {
    enabled: true
    displayName:'VM_failed_login'
    description: 'VM_failed_login'
    scopes: [
      workspaceId
    ]
    actions: {
      actionGroups: [
        actionGroup
      ]
    }
    criteria: {
      allOf: [
        {
          query: 'SecurityEvent \n| where EventID == 4625 \n | summarize count() by TargetAccount, Computer, _ResourceId\n'
          threshold: 1
          operator: 'LessThan'
          timeAggregation: 'Count'
          failingPeriods: {
            minFailingPeriodsToAlert: 1
            numberOfEvaluationPeriods: 1
          }
        }
      ]
    }
    evaluationFrequency: 'PT1M'
    severity: 2
    windowSize: 'PT1M'
    autoMitigate: true
  }
}
