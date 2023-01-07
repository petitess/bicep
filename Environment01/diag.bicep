targetScope = 'subscription'

param name string
param workspaceId string

var categories = [
  'Administrative'
  'Security'
  'ServiceHealth'
  'Alert'
  'Recommendation'
  'Policy'
  'Autoscale'
  'ResourceHealth'
]

resource logdiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: name
  properties: {
    workspaceId: workspaceId
    logs: [for category in categories:{
      category: category
      enabled: true
        }]
      }
}
