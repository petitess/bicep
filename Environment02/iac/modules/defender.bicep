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
    pricingTier: 'Free'
  }
  {
    name: 'Containers'
    pricingTier: 'Standard'
  }
  {
    name: 'CloudPosture'
    pricingTier: 'Standard'
  }
]

@batchSize(1)
resource defenderPlan 'Microsoft.Security/pricings@2024-01-01' = [
  for plan in defenderPlans: {
    name: plan.name
    properties: {
      pricingTier: plan.pricingTier
    }
  }
]
