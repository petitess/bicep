targetScope = 'resourceGroup'

param name string
param tags object
param virtualMachines array

resource actiongrp 'Microsoft.Insights/actionGroups@2022-04-01' = {
  name: name
  location: 'global'
  tags: tags
  properties: {
    enabled:  true
    groupShortName: name
    emailReceivers: [
      {
        name: 'Karol'
        emailAddress: 'karol.sek@yourmail.com'
      }
    ]
  }
}

 resource vmexisting 'Microsoft.Compute/virtualMachines@2021-11-01' existing = [for vm in virtualMachines: {
   name: vm.name
   scope: resourceGroup('rg-${vm.name}')
 }]


resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = [for (vm, i) in virtualMachines: {
  name: vm.name
  location: 'global'
  properties: {
    description: 'Response time alert'
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
        actionGroupId: actiongrp.id
      }
    ]
  }
}]

