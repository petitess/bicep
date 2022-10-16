targetScope = 'resourceGroup'

param name string
param param object
param maintenanceid string

resource vmx 'Microsoft.Compute/virtualMachines@2022-08-01' existing = {
  name: name
}

resource assignments 'Microsoft.Maintenance/configurationAssignments@2021-09-01-preview' = {
  scope: vmx
  name: '${name}-assignments'
  location: param.location
  properties: {
    maintenanceConfigurationId: maintenanceid
    resourceId: resourceId('Microsoft.Compute/virtualMachines', name)
  }
}


