targetScope = 'resourceGroup'

param tags object
param actionGroupId string

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
      ]
    }
    enabled: true
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
    enabled: true
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
