targetScope = 'resourceGroup'

param location string
param workspaceId string

var tags = resourceGroup().tags

resource alert1 'Microsoft.Insights/scheduledQueryRules@2021-08-01' = {
  name: 'alert-VM_failed_login'
  location: location
  tags: tags
  properties: {
    enabled: true
    displayName:'alert-VM_failed_login'
    description: 'alert-VM_failed_login'
    scopes: [
      workspaceId
    ]
    // actions: {
    //   actionGroups: [
    //     actionGroup
    //   ]
    // }
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


resource alert2 'Microsoft.Insights/scheduledQueryRules@2021-08-01' = {
  name: 'alert-UpdateSummery01'
  location: location
  tags: tags
  properties: {
    enabled: true
    displayName:'alert-UpdateSummery01'
    description: 'alert-UpdateSummery01'
    scopes: [
      subscription().id
    ]
    // actions: {
    //   actionGroups: [
    //     actionGroup
    //   ]
    // }
    criteria: {
      allOf: [
        {
          query:  '''
// Defining business day display names and business hours lookup table
let businessInterval = datatable (
dayOfWeekTimespan: int,
dayOfWeekDayDisplayName: string,
firstH: int,
lastH: int
) [
0, "Monday", 7, 18,
1, "Tuesday", 7, 18,
2, "Wednesday", 7, 18,
3, "Thursday", 7, 18,
4, "Friday", 7, 18,
5, "Saturday", 7, 18,
6, "Sunday", 7, 18
];
// Defining timerange interval
//let startDate = ago(1d);
//let endDate = now();
UpdateSummary
//| where TimeGenerated between (startDate .. endDate)
| extend dayOfWeekTimespan = toint(substring(tostring(dayofweek(TimeGenerated)), 0, 1))
| where dayOfWeekTimespan in (4)
| lookup kind=leftouter businessInterval on dayOfWeekTimespan
| where datetime_part("Hour", TimeGenerated) between (firstH .. lastH)
| where CriticalUpdatesMissing > 0 or SecurityUpdatesMissing > 0
| summarize by Computer, CriticalUpdatesMissing, SecurityUpdatesMissing, TimeGenerated
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
    evaluationFrequency: 'P1D'
    overrideQueryTimeRange: 'P2D'
    severity: 3
    windowSize: 'P1D'
    autoMitigate: false
  }
}

