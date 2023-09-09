targetScope = 'tenant'

param subscriptions array
param billingScope string

@batchSize(1)
resource subscriptionAlias 'Microsoft.Subscription/aliases@2021-10-01' = [for sub in subscriptions: {
  scope: tenant()
  name: sub
  properties: {
    workload: 'Production'
    displayName: sub
    billingScope: billingScope
  }
}]

output subIds array = [for (subs, i) in subscriptions: {
  id: subscriptionAlias[i].properties.subscriptionId
}]
