targetScope = 'tenant'

param subscriptions array
param subId array

resource mainManagementGroup 'Microsoft.Management/managementGroups@2021-04-01' existing = {
  name: 'mg-sek-prod-01'
  scope: tenant()
}

@batchSize(1)
resource subscriptionResources 'Microsoft.Management/managementGroups/subscriptions@2021-04-01' = [for (sub, i) in subscriptions: {
  parent: mainManagementGroup
  name: subId[i].id
}]
