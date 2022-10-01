targetScope = 'resourceGroup'

param name string
param location string

param log string
param logApi string

var tags = resourceGroup().tags

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' existing = {
  name: name
}

resource workspaceExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  parent: vm
  name: 'MicrosoftMonitoringAgent'
  location: location
  tags: tags
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    settings: {
      workspaceId: reference(log, logApi).customerId
    }
    protectedSettings: {
      workspaceKey: listKeys(log, logApi).primarySharedKey
    }
  }
}
