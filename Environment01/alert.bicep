targetScope = 'resourceGroup'

param tags object
param actionGroupId string

resource azurealert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: 'ServiceHealth_Information'
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
              'West Europe'
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
  name: 'ServiceHealth_Warning'
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
              'West Europe'
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
