targetScope = 'tenant'

param billingAccounts string
param billingProfile string
param invoiceSections string
param billingScope string = resourceId('Microsoft.Billing/billingAccounts/billingProfiles/invoiceSections', billingAccounts, billingProfile, invoiceSections)

//https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/create-subscriptions-deploy-resources
param subscriptions array = [
  'sub-sek-test-01'
  'sub-sek-test-02'
  'sub-sek-test-03'
]

module newSub 'sub.bicep' = {
  name: 'new-subscriptions'
  params: {
    billingScope: billingScope
    subscriptions: subscriptions
  }
}

module connectMg 'mg.bicep' = {
  name: 'add-subscriptions'
  dependsOn: [ newSub ]
  params: {
    subId: newSub.outputs.subIds
    subscriptions: subscriptions
  }
}
