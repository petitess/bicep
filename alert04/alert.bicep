targetScope = 'resourceGroup'

param actionGroup string

var tags = resourceGroup().tags

resource vmhealth 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: 'AllVMs-health'
  location: 'Global'
  tags: tags
  properties: {
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroup
        }
      ]
    }
    condition: {
      allOf:  [
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
            {
              field: 'status'
              equals: 'Resolved'
            }
            {
              field: 'status'
              equals: 'Updated'
            }
          ]
        }
        {
          anyOf: [
            {
              field: 'properties.previousHealthStatus'
              equals: 'Unavailable'
            }
            {
              field: 'properties.previousHealthStatus'
              equals: 'Unknown'
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
