targetScope = 'resourceGroup'

param location string
param tags object
param actionGroupId string
param time string = dateTimeAdd(utcNow(), 'PT1M', 'yyyy-MM-ddTHH:mm:ss')

resource azurealert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: 'ServiceHealth_Information_${subscription().displayName}'
  tags: tags
  location: 'global'
  properties: {
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'ServiceHealth'
        }
        {
          field: 'properties.incidentType'
          equals: 'Maintenance'
        }
        {
          field: 'properties.impactedServices[*].ImpactedRegions[*].RegionName'
          containsAny: [
            'Global'
            'Sweden Central'
          ]
        }
        {
          field: 'properties.impactedServices[*].ServiceName'
          containsAny: [
            'Activity Logs & Alerts'
            'Action Groups'
            'Alerts'
            'Alerts & Metrics'
            'Automation'
            'Azure Active Directory'
            'Azure Bastion'
            'Azure DNS'
            'Azure DevOps'
            'Azure DevOps \\ Artifacts'
            'Azure DevOps \\ Boards'
            'Azure DevOps \\ Pipelines'
            'Azure DevOps \\ Repos'
            'Azure DevOps \\ Test Plans'
            'Azure Key Vault Managed HSM'
            'Azure Monitor'
            'Azure Private Link'
            'Azure Resource Manager'
            'Recovery Services vault'
            'Backup vault'
            'Cloud Services'
            'Cloud Shell'
            'Cost Management'
            'Key Vault'
            'Log Analytics'
            'Marketplace'
            'Microsoft Azure portal'
            'Microsoft Azure portal \\ Marketplace'
            'Microsoft Defender for Cloud'
            'Multi-Factor Authentication'
            'Network Infrastructure'
            'Network Watcher'
            'SQL Server on Azure Virtual Machines'
            'Scheduler'
            'Security Center'
            'Storage'
            'Subscription Management'
            'VPN Gateway'
            'VPN Gateway \\ Virtual WAN'
            'Virtual Machines'
            'Virtual Network'
            'Windows Virtual Desktop'
          ]
        }
      ]
    }
    enabled: false
    scopes: [
      subscription().id
    ]
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroupId
        }
      ]
    }
  }
}

resource azurealert2 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: 'ServiceHealth_Warning_${subscription().displayName}'
  tags: tags
  location: 'global'
  properties: {
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'ServiceHealth'
        }
        {
          field: 'properties.incidentType'
          equals: 'Incident'
        }
        {
          field: 'properties.incidentType'
          equals: 'Security'
        }
        {
          field: 'properties.impactedServices[*].ImpactedRegions[*].RegionName'
          containsAny: [
            'Global'
            'Sweden Central'
          ]
        }
        {
          field: 'properties.impactedServices[*].ServiceName'
          containsAny: [
            'Activity Logs & Alerts'
            'Action Groups'
            'Alerts'
            'Alerts & Metrics'
            'Automation'
            'Azure Active Directory'
            'Azure Bastion'
            'Azure DNS'
            'Azure DevOps'
            'Azure DevOps \\ Artifacts'
            'Azure DevOps \\ Boards'
            'Azure DevOps \\ Pipelines'
            'Azure DevOps \\ Repos'
            'Azure DevOps \\ Test Plans'
            'Azure Key Vault Managed HSM'
            'Azure Monitor'
            'Azure Private Link'
            'Azure Resource Manager'
            'Recovery Services vault'
            'Backup vault'
            'Cloud Services'
            'Cloud Shell'
            'Cost Management'
            'Key Vault'
            'Log Analytics'
            'Marketplace'
            'Microsoft Azure portal'
            'Microsoft Azure portal \\ Marketplace'
            'Microsoft Defender for Cloud'
            'Multi-Factor Authentication'
            'Network Infrastructure'
            'Network Watcher'
            'SQL Server on Azure Virtual Machines'
            'Scheduler'
            'Security Center'
            'Storage'
            'Subscription Management'
            'VPN Gateway'
            'VPN Gateway \\ Virtual WAN'
            'Virtual Machines'
            'Virtual Network'
            'Windows Virtual Desktop'
          ]
        }
      ]
    }
    enabled: false
    scopes: [
      subscription().id
    ]
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroupId
        }
      ]
    }
  }
}

resource alert 'Microsoft.Insights/scheduledQueryRules@2022-06-15' = {
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
    evaluationFrequency: 'PT6H'
    severity: 3
    windowSize: 'PT6H'
    autoMitigate: false
  }
}

resource enable01 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  name: 'enable-${alert.name}'
  location: 'global'
  tags: tags
  properties: {
    enabled: true
    description: 'Enables Log query alert. Enabled every friday'
    actions: [
      {
        actionType: 'AddActionGroups'
        actionGroupIds: [
          actionGroupId
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
            'Friday'
          ]
          recurrenceType: 'Weekly'
          startTime: '00:01:00'
          endTime: '12:10:00'
        }
      ]
    }
    conditions: [
      {
        field: 'AlertRuleName'
        operator: 'Equals'
        values: [
          alert.name
        ]
      }
    ]
  }
}

resource vmhealth 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: 'alert-VMs-health'
  location: 'Global'
  tags: tags
  properties: {
    enabled: true
    description: 'Resource health alerts for all virtual machines. Go to Azure Monitor to see more information'
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroupId
        }
      ]
    }
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'ResourceHealth'
        }
        {
          anyOf: [
            {
              field: 'properties.cause'
              equals: 'Unknown'
            }
            {
              field: 'properties.cause'
              equals: 'PlatformInitiated'
            }
          ]
        }
        {
          anyOf: [
            {
              field: 'properties.currentHealthStatus'
              equals: 'Unavailable'
            }
          ]
        }
        {
          anyOf: [
            {
              field: 'status'
              equals: 'Active'
            }
          ]
        }
        {
          anyOf: [
            {
              field: 'properties.previousHealthStatus'
              equals: 'Available'
            }
          ]
        }
        {
          anyOf: [
            {
              field: 'resourceType'
              equals: 'microsoft.compute/virtualmachines'
            }
          ]
        }
      ]
    }
    scopes: [
      subscription().id
    ]
  }
}
