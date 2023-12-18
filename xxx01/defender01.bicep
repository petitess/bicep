targetScope = 'subscription'

var defenderPlans = [
  {
    name: 'VirtualMachines'
    pricingTier: 'Standard'
  }
  {
    name: 'SqlServers'
    pricingTier: 'Standard'
  }
  {
    name: 'AppServices'
    pricingTier: 'Standard'
  }
  {
    name: 'StorageAccounts'
    pricingTier: 'Standard'
  }
  {
    name: 'SqlServerVirtualMachines'
    pricingTier: 'Standard'
  }
  {
    name: 'KubernetesService'
    pricingTier: 'Standard'
  }
  {
    name: 'ContainerRegistry'
    pricingTier: 'Standard'
  }
  {
    name: 'KeyVaults'
    pricingTier: 'Standard'
  }
  {
    name: 'Dns'
    pricingTier: 'Standard'
  }
  {
    name: 'Arm'
    pricingTier: 'Standard'
  }
  {
    name: 'OpenSourceRelationalDatabases'
    pricingTier: 'Standard'
  }
  {
    name: 'CosmosDbs'
    pricingTier: 'Standard'
  }
  {
    name: 'Containers'
    pricingTier: 'Standard'
  }
  {
    name: 'CloudPosture'
    pricingTier: 'Standard'
  }
  {
    name: 'Api'
    pricingTier: 'Standard'
  }

]
@batchSize(1)
resource defenderPlan 'Microsoft.Security/pricings@2023-01-01' = [for plan in defenderPlans: {
  name: plan.name
  properties: {
    pricingTier: plan.pricingTier
  }
}]
