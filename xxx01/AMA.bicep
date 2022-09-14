resource workspaceExtension2 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (extensions) {
  parent: vm
  name: 'AzureMonitorWindowsAgent'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.8'
    settings: {
      authentication: {
        managedIdentity: {
          'identifier-name': 'mi_res_id'
          'identifier-value': userAssignedManagedIdentityId
        }
      }
      workspaceId: reference(log, logApi).customerId
      protectedSettings: {
        workspaceKey: listKeys(log, logApi).primarySharedKey
      }
    }

  }
}
