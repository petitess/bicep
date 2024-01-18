param name string = 'DESKTOP-E23A7BK'

resource arcs 'Microsoft.HybridCompute/machines@2023-10-03-preview' = {
  name: name
  location: 'westeurope'
  tags: {
    CostCenter: '9100'
    Environment: 'Development'
    Product: 'Common Infrastructure'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    osType: 'windows'
    osProfile: {}
    vmId: '8d22a3fe-6991-4f3b-9295-66482ce0ecb1'
    clientPublicKey: 'MIIBCgKCAQEArcJ21HjUjbPHDWh0MJImmAUi9DAShSV2YNz0FcycrfLILKuZd2TYI3Ey2lSgdbkGxzPQ1Nf7UP9w6b0d8m8sRuF4qS6gV2AJ7jMKwIDAQAB'
    mssqlDiscovered: 'false'
    cloudMetadata: {}
    detectedProperties: {
      cloudprovider: 'N/A'
      coreCount: '4'
      logicalCoreCount: '4'
      manufacturer: 'ASUSTeK COMPUTER INC.'
      model: 'GL753VD'
      mssqldiscovered: 'false'
      processorCount: '1'
      processorNames: 'Intel(R) Core(TM) i5-7300HQ CPU @ 2.50GHz'
      productType: '101'
      serialNumber: 'CSN12345678901234567'
      smbiosAssetTag: ' No  Asset  Tag '
      totalPhysicalMemoryInBytes: '25769803776'
      totalPhysicalMemoryInGigabytes: '24'
    }
    agentConfiguration: {}
    serviceStatuses: {
      extensionService: {
        status: 'running'
        startupType: 'automatic'
      }
      guestConfigurationService: {
        status: 'running'
        startupType: 'automatic'
      }
    }
    agentUpgrade: {
      enableAutomaticUpgrade: false
    }
    networkProfile: {
      networkInterfaces: [
        {
          ipAddresses: [
            {
              address: '10.0.60.92'
              ipAddressVersion: 'IPv4'
              subnet: {
                addressPrefix: '10.0.60.0/24'
              }
            }
          ]
        }
      ]
    }
    licenseProfile: {
      esuProfile: {
        licenseAssignmentState: 'NotAssigned'
      }
    }
  }
}

resource extMde 'Microsoft.HybridCompute/machines/extensions@2023-06-20-preview' = {
  parent: arcs
  name: 'MDE.Windows'
  location: 'westeurope'
  tags: {
    CostCenter: '9100'
    Environment: 'Development'
    Product: 'Common Infrastructure'
  }
  properties: {
    publisher: 'Microsoft.Azure.AzureDefenderForServers'
    type: 'MDE.Windows'
    typeHandlerVersion: '1.0.9.4'
    autoUpgradeMinorVersion: false
    enableAutomaticUpgrade: true
    settings: {
      azureResourceId: arcs.id
      forceReOnboarding: false
      vNextEnabled: true
      autoUpdate: true
    }
    instanceView: {
      name: 'MDE.Windows'
      type: 'MDE.Windows'
      typeHandlerVersion: '1.0.9.4'
      status: {
        code: '51'
        level: 'Error'
        message: 'Extension Message: Failed to configure Microsoft Defender for Endpoint: Onboarding to MDE via Microsoft Defender for Cloud for this operating system is not supported. Read more about supported operating systems: https://docs.microsoft.com/en-us/azure/defender-for-cloud/integration-defender-for-endpoint?tabs=linux#availability, executionlog: [2024-01-18 14:38:03Z][Information] Attempting to read Arc proxy settings\r\n[2024-01-18 14:38:03Z][Information] Arc proxy was not set. No custom proxy will be used\r\n[2024-01-18 14:38:03Z][Information] Path HKLM:\\Software\\Policies\\Microsoft\\Windows Advanced Threat Protection already exists\r\n[2024-01-18 14:38:03Z][Information] Path HKLM:\\Software\\Policies\\Microsoft\\Windows\\DataCollection already exists\r\n[2024-01-18 14:38:03Z][Information] Proxy URI is empty -> disable proxy\r\n[2024-01-18 14:38:03Z][Information] Try to get MDE onboarding package applicability\r\n[2024-01-18 14:38:03Z][Information] MDE onboarding package applicability: 0\r\n[2024-01-18 14:38:03Z][Error] Onboarding to MDE via Microsoft Defender for Cloud for this operating system is not supported. Read more about supported operating systems: https://docs.microsoft.com/en-us/azure/defender-for-cloud/integration-defender-for-endpoint?tabs=linux#availability \r\n[2024-01-18 14:38:03Z][Error] Failed to configure Microsoft Defender for Endpoint: Onboarding to MDE via Microsoft Defender for Cloud for this operating system is not supported. Read more about supported operating systems: https://docs.microsoft.com/en-us/azure/defender-for-cloud/integration-defender-for-endpoint?tabs=linux#availability\r\n[2024-01-18 14:38:03Z][Information] Set handler status (C:\\Packages\\Plugins\\Microsoft.Azure.AzureDefenderForServers.MDE.Windows\\1.0.9.4\\status\\0.status), Status=error, Code=51, Message=\'Failed to configure Microsoft Defender for Endpoint: Onboarding to MDE via Microsoft Defender for Cloud for this operating system is not supported. Read more about supported operating systems: https://docs.microsoft.com/en-us/azure/defender-for-cloud/integration-defender-for-endpoint?tabs=linux#availability\'\nExtension Error: \nC:\\Packages\\Plugins\\Microsoft.Azure.AzureDefenderForServers.MDE.Windows\\1.0.9.4>Powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass C:\\Packages\\Plugins\\Microsoft.Azure.AzureDefenderForServers.MDE.Windows\\1.0.9.4\\\\MdeExtensionHandlerWrapper.ps1 -Action enable \nVERBOSE: [2024-01-18 14:37:54Z][Information] Start executing handler action: enable\nVERBOSE: [2024-01-18 14:37:56Z][Information] Set handler status \n(C:\\Packages\\Plugins\\Microsoft.Azure.AzureDefenderForServers.MDE.Windows\\1.0.9.4\\status\\0.status), \nStatus=transitioning, Code=1, Message=\'Configuration In Progress\'\nVERBOSE: [2024-01-18 14:37:56Z][Information] Invoking MdeExtensionHandler.ps1 in background process in order to \ninstall/configuration/onboard MDE\nVERBOSE: [2024-01-18 14:37:56Z][Information] End executing handler action: enable with exit code: 0\n\nC:\\Packages\\Plugins\\Microsoft.Azure.AzureDefenderForServers.MDE.Windows\\1.0.9.4>Powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass C:\\Packages\\Plugins\\Microsoft.Azure.AzureDefenderForServers.MDE.Windows\\1.0.9.4\\\\MdeExtensionHandlerWrapper.ps1 -Action install \nVERBOSE: [2024-01-18 14:00:46Z][Information] Start executing handler action: install\nVERBOSE: [2024-01-18 14:00:46Z][Information] MDE installation/configuration/onboarding occurs / will occur in \'enable\'\nVERBOSE: [2024-01-18 14:00:46Z][Information] End executing handler action: install with exit code: 0\n\nC:\\Packages\\Plugins\\Microsoft.Azure.AzureDefenderForServers.MDE.Windows\\1.0.9.4>Powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass C:\\Packages\\Plugins\\Microsoft.Azure.AzureDefenderForServers.MDE.Windows\\1.0.9.4\\\\MdeExtensionHandlerWrapper.ps1 -Action enable \nVERBOSE: [2024-01-18 14:00:49Z][Information] Start executing handler action: enable\nVERBOSE: [2024-01-18 14:00:50Z][Information] Set handler status \n(C:\\Packages\\Plugins\\Microsoft.Azure.AzureDefenderForServers.MDE.Windows\\1.0.9.4\\status\\0.status), \nStatus=transitioning, Code=1, Message=\'Configuration In Progress\'\nVERBOSE: [2024-01-18 14:00:50Z][Information] Invoking MdeExtensionHandler.ps1 in background process in order to \ninstall/configuration/onboard MDE\nVERBOSE: [2024-01-18 14:00:51Z][Information] End executing handler action: enable with exit code: 0\n'
      }
    }
  }
}

resource extMMA 'Microsoft.HybridCompute/machines/extensions@2023-06-20-preview' = {
  parent: arcs
  name: 'MicrosoftMonitoringAgent'
  location: 'westeurope'
  tags: {
    CostCenter: '9100'
    Environment: 'Development'
    Product: 'Common Infrastructure'
  }
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0.18069.0'
    autoUpgradeMinorVersion: false
    enableAutomaticUpgrade: true
    settings: {
      workspaceId: '1f0e6d4c-8f84-4f97-93b8-f0582652580b'
      stopOnMultipleConnections: 'true'
    }
    instanceView: {
      name: 'MicrosoftMonitoringAgent'
      type: 'MicrosoftMonitoringAgent'
      typeHandlerVersion: '1.0.18069.0'
      status: {
        code: '0'
        level: 'Information'
        message: 'Extension Message: Latest configuration has been applied to the Microsoft Monitoring Agent.'
      }
    }
  }
}

resource machines_DESKTOP_E23A7BK_name_default 'Microsoft.HybridCompute/machines/licenseProfiles@2023-06-20-preview' = {
  parent: arcs
  name: 'default'
  location: 'westeurope'
  properties: {
    esuProfile: {}
  }
}
