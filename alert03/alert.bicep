targetScope = 'resourceGroup'

param location string
param actionGroup string
param basetime string = dateTimeAdd(utcNow(), 'PT1M', 'yyyy-MM-ddTHH:mm:ss') 

var tags = resourceGroup().tags
var alertname01 = 'info-UpdateSummery-test'

resource alert01 'Microsoft.Insights/scheduledQueryRules@2021-08-01' = {
  name: alertname01
  location: location
  tags: tags
  properties: {
    enabled: true
    displayName:alertname01
    description: alertname01
    scopes: [
      subscription().id
    ]
    actions: {
      actionGroups: [
        actionGroup
      ]
    }
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

resource suppression01 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  name: 'disable-${alertname01}'
  location: 'global'
  tags: tags
  properties: {
    enabled: true
    description: 'Disables Log query alert. Enabled the 1st day of each month'
    actions: [
     {
      actionType: 'RemoveAllActionGroups'
     } 
    ]
    scopes: [
      alert01.id
    ]
    schedule: {
      timeZone: 'W. Europe Standard Time'
      effectiveFrom: basetime
      recurrences: [
        {
          recurrenceType: 'Monthly'
          daysOfMonth:  [
            2
            3
            4
            5
            6
            7
            8
            9
            10
            11
            12
            13
            14
            15
            16
            17
            18
            19
            20
            21
            22
            23
            24
            25
            26
            27
            28
            29
            30
            31
          ]
        }
      ]
    }
  }
}


output a string = basetime
