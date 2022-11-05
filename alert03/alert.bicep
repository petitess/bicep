targetScope = 'resourceGroup'

param location string
param actionGroup string
param time string = dateTimeAdd(utcNow(), 'PT1M', 'yyyy-MM-ddTHH:mm:ss')

var tags = resourceGroup().tags

resource alert2 'Microsoft.Insights/scheduledQueryRules@2021-08-01' = {
  name: 'info-UpdateSummery01'
  location: location
  tags: tags
  properties: {
    enabled: true
    displayName: 'info-UpdateSummery01'
    description: 'info-UpdateSummery01'
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
          query: '''
UpdateSummary
| where CriticalUpdatesMissing > 0 or SecurityUpdatesMissing > 0
| where TimeGenerated > ago(30d)
| distinct  Computer, CriticalUpdatesMissing, SecurityUpdatesMissing, _ResourceId
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
    severity: 3
    windowSize: 'P1D'
    autoMitigate: false
  }
}

resource suppression01 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  name: 'disable-${alert2.name}'
  location: 'global'
  tags: tags
  properties: {
    enabled: true
    description: 'Disables Log query alert. Enabled every friday'
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
          daysOfWeek: [
            'Monday'
            'Tuesday'
            'Wednesday'
            'Thursday'
            'Saturday'
            'Sunday'
          ]
          recurrenceType: 'Weekly'
        }
      ]
    }
    conditions: [
      {
        field: 'AlertRuleName'
        operator: 'Equals'
        values: [
          alert2.name
        ]
      }
    ]
  }
}

resource alert3 'Microsoft.Insights/scheduledQueryRules@2021-08-01' = {
  name: 'info-UpdateSummery02'
  location: location
  tags: tags
  properties: {
    enabled: true
    displayName: 'info-UpdateSummery02'
    description: 'info-UpdateSummery02'
    scopes: [
      subscription().id
    ]
    actions: {
      actionGroups: []
    }
    criteria: {
      allOf: [
        {
          query: '''
UpdateSummary
| where CriticalUpdatesMissing > 0 or SecurityUpdatesMissing > 0
| where TimeGenerated > ago(30d)
| distinct  Computer, CriticalUpdatesMissing, SecurityUpdatesMissing, _ResourceId
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
    severity: 3
    windowSize: 'P1D'
    autoMitigate: false
  }
}

resource enable01 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  name: 'enable-${alert3.name}'
  location: 'global'
  tags: tags
  properties: {
    enabled: true
    description: 'Enabled every Saturday'
    actions: [
      {
        actionType: 'AddActionGroups'
        actionGroupIds: [
          actionGroup
        ]
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
          daysOfWeek: [
            'Saturday'
          ]
          recurrenceType: 'Weekly'
        }
      ]
    }
    conditions: [
      {
        field: 'AlertRuleName'
        operator: 'Equals'
        values: [
          alert3.name
        ]
      }
    ]
  }
}
