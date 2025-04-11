param location string
param emailReceivers ({name: string, emailAddress: string })[]

resource actionGroups_emailAlert 'Microsoft.Insights/actionGroups@2024-10-01-preview' = {
  name: 'ag-dbace01'
  location: 'global'
  properties: {
    groupShortName: 'ag-dbace01'
    enabled: true
    emailReceivers: emailReceivers
  }
}

resource alert2 'Microsoft.Insights/scheduledQueryRules@2025-01-01-preview' = {
  name: 'vmdbace01-restart-required'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    displayName: 'vmdbace01-restart-required'
    description: 'vmdbace01 is Required to reboot after update.'
    scopes: [
      subscription().id
    ]
    actions: {
      actionGroups: [
        actionGroups_emailAlert.id
      ]
    }
    criteria: {
      allOf: [
        {
          query: '''
arg('').patchinstallationresources
| where type in~ ("microsoft.compute/virtualmachines/patchinstallationresults", "microsoft.hybridcompute/machines/patchinstallationresults")
| where properties.status =~ "CompletedWithWarnings"
| where resourceGroup == 'rg-vmdbace01'
| where properties.lastModifiedDateTime > ago(1d)
| where properties.errorDetails.details[0].message contains 'Machine is Required to reboot'
| parse id with vmResourceId "/patchInstallationResults" *
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
    evaluationFrequency: 'PT10M'
    severity: 3
    windowSize: 'PT10M'
    autoMitigate: true
  }
}
