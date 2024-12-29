targetScope = 'subscription'

param name string
param mcId string
param detectionTags object

resource dynamicScope 'Microsoft.Maintenance/configurationAssignments@2023-10-01-preview' = {
  name: 'scope-${name}'
  properties: {
    maintenanceConfigurationId: mcId
    filter: {
      osTypes: [
        'Windows'
        'Linux'
      ]
      resourceTypes: [
        'microsoft.compute/virtualmachines'
        'microsoft.hybridcompute/machines'
      ]
      tagSettings: {
        filterOperator: 'All'
        tags: detectionTags
      }
    }
  }
}
