///subscriptions/123abc/providers/Microsoft.Security/pricings?api-version=2024-01-01
targetScope = 'subscription'

var defenderPlans = [
  {
    name: 'VirtualMachines'
    properties: {
      pricingTier: 'Standard'
      subPlan: 'P2'
      extensions: [
        {
          name: 'MdeDesignatedSubscription'
          isEnabled: 'False'
        }
        {
          name: 'AgentlessVmScanning'
          isEnabled: 'True'
        }
        {
          name: 'FileIntegrityMonitoring'
          isEnabled: 'False'
        }
      ]
    }
  }
  {
    name: 'SqlServers'
    properties: {
      pricingTier: 'Standard'
    }
  }
  {
    name: 'AppServices'
    properties: {
      pricingTier: 'Standard'
    }
  }
  {
    name: 'StorageAccounts'
    properties: {
      resourcesCoverageStatus: 'FullyCovered'
      extensions: [
        {
          name: 'OnUploadMalwareScanning'
          isEnabled: 'True'
          additionalExtensionProperties: {
            CapGBPerMonthPerStorageAccount: '10000'
            BlobScanResultsOptions: 'BlobIndexTags'
            AutomatedResponse: 'None'
          }
        }
        {
          name: 'SensitiveDataDiscovery'
          isEnabled: 'True'
        }
      ]
      subPlan: 'DefenderForStorageV2'
      pricingTier: 'Standard'
    }
  }
  {
    name: 'SqlServerVirtualMachines'
    properties: {
      pricingTier: 'Standard'
    }
  }
  {
    name: 'KeyVaults'
    properties: {
      pricingTier: 'Standard'
      subPlan: 'PerKeyVault'
    }
  }
  {
    name: 'Arm'
    properties: {
      pricingTier: 'Standard'
      subPlan: 'PerSubscription'
    }
  }
  {
    name: 'OpenSourceRelationalDatabases'
    properties: {
      pricingTier: 'Free'
    }
  }
  {
    name: 'Containers'
    properties: {
      pricingTier: 'Standard'
      extensions: [
        {
          name: 'ContainerRegistriesVulnerabilityAssessments'
          isEnabled: 'True'
        }
        {
          name: 'AgentlessDiscoveryForKubernetes'
          isEnabled: 'True'
        }
        {
          name: 'AgentlessVmScanning'
          isEnabled: 'True'
        }
        {
          name: 'ContainerSensor'
          isEnabled: 'True'
        }
      ]
    }
  }
  {
    name: 'CloudPosture'
    properties: {
      pricingTier: 'Standard'
      extensions: [
        {
          name: 'SensitiveDataDiscovery'
          isEnabled: 'True'
        }
        {
          name: 'ContainerRegistriesVulnerabilityAssessments'
          isEnabled: 'True'
        }
        {
          name: 'AgentlessDiscoveryForKubernetes'
          isEnabled: 'True'
        }
        {
          name: 'AgentlessVmScanning'
          isEnabled: 'True'
        }
        {
          name: 'EntraPermissionsManagement'
          isEnabled: 'True'
        }
        {
          name: 'ApiPosture'
          isEnabled: 'True'
        }
      ]
    }
  }
  {
    name: 'CosmosDbs'
    properties: {
      pricingTier: 'Standard'
    }
  }
  {
    name: 'Api'
    properties: {
      pricingTier: 'Free'
    }
  }
]

@batchSize(1)
resource defenderPlan 'Microsoft.Security/pricings@2024-01-01' = [
  for plan in defenderPlans: {
    name: plan.name
    properties: plan.properties
  }
]
