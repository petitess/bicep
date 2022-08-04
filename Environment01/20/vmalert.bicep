targetScope = 'resourceGroup'

param tags object
param virtualMachines array
param actionGroupId string

 resource vmexisting 'Microsoft.Compute/virtualMachines@2021-11-01' existing = [for vm in virtualMachines: {
   name: vm.name
   scope: resourceGroup('rg-${vm.name}')
 }]

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = [for (vm, i) in virtualMachines: if(vm.VMalerts) {
  name: '${vm.name}_cpu'
  location: 'global'
  tags: tags
  properties: {
    description: 'CPU usage'
    severity: 3
    enabled: true
    scopes: [
      vmexisting[i].id
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: '1st criterion'
          metricName: 'Percentage CPU'
          operator: 'GreaterThan'
          threshold: 90 
          timeAggregation: 'Minimum'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
}]

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
