resource DependencyAgentExtension 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = if (osWindows) {
  parent: vm
  name: 'DependencyAgentWindows'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentWindows'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }
}

resource encryptionExtensionWindows 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = if (osWindows && tags.Environment == 'Test') {
  parent: vm
  name: 'AzureDiskEncryption'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Azure.Security'
    type: 'AzureDiskEncryption'
    typeHandlerVersion: '2.2'
    settings: {
      EncryptionOperation: 'EnableEncryption'
      KeyEncryptionAlgorithm: 'RSA-OAEP'
      VolumeType: 'All'
      KeyVaultURL: kvUrl
      KeyVaultResourceId: kvId
      KeyEncryptionKeyURL: keyUrl
      KekVaultResourceId: kvId
    }
  }
}

resource IaaSAntimalwareExtension 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = if (osWindows) {
  parent: vm
  name: 'IaaSAntimalware'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      AntimalwareEnabled: true
      RealtimeProtectionEnabled: true
      ScheduledScanSettings: {
        isEnabled: true
        day: 1
        time: 1320
        scanType: 'Quick'
      }
      Exclusions: {
        Extensions: ''
        Paths: ''
        Processes: ''
      }
    }
  }
}

resource AMA 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = if (extensions || contains(imageReference.publisher, 'canonical')) {
  parent: vm
  name: contains(imageReference.publisher, 'windows') || contains(imageReference.publisher, 'microsoft') ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    publisher: 'Microsoft.Azure.Monitor'
    type: contains(imageReference.publisher, 'windows') || contains(imageReference.publisher, 'microsoft') ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
    typeHandlerVersion: contains(imageReference.publisher, 'windows') || contains(imageReference.publisher, 'microsoft') ? '1.8' : '1.25'
    settings: {
      authentication: {
        managedIdentity: {
          'identifier-name': 'mi_res_id'
          'identifier-value': vm.id
        }
      }
    }
  }
}
