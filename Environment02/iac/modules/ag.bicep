targetScope = 'resourceGroup'

param location string
param tags object = resourceGroup().tags

var emailReceivers = [
  {
    name: 'Servicedesk_EmailAction'
    emailAddress: 'support@company.com'
    useCommonAlertSchema: false
  }
]
var webhooks = [
  {
    name: 'X3-P3-Bas'
    shortName: 'P3-Bas'
    enabled: true
    webhookReceivers: [
      {
        name: 'X3BasWebhook'
        serviceUri: 'https://api.opsgenie.com/v1/json/azure?apiKey=xxxxxxxxxxxxxxxxxxx'
        useCommonAlertSchema: true
        useAadAuth: false
      }
    ]
  }
  {
    name: 'X3-P5-Bas'
    shortName: 'P5-Bas'
    enabled: true
    webhookReceivers: [
      {
        name: 'P5BasWebhook'
        serviceUri: 'https://api.opsgenie.com/v1/json/azure?apiKey=xxxxxxxxxxxxxxxxxxxxxxxx'
        useCommonAlertSchema: true
        useAadAuth: false
      }
    ]
  }
]

resource actionGroups_emailAlert 'Microsoft.Insights/actionGroups@2024-10-01-preview' = {
  name: 'X3 Support Email Alert'
  location: location
  tags: tags
  properties: {
    groupShortName: 'EmailAlert'
    enabled: true
    emailReceivers: emailReceivers
  }
}

resource actionGroups_webhookAlert 'Microsoft.Insights/actionGroups@2024-10-01-preview' = [for webhook in webhooks: {
  name: webhook.name
  location: location
  tags: tags
  properties: {
    groupShortName: webhook.shortName
    enabled: webhook.enabled
    webhookReceivers: webhook.webhookReceivers
  }
}]

output agP3Bas string = actionGroups_webhookAlert[0].id
output agP5Bas string = actionGroups_webhookAlert[1].id
output agEmail string = actionGroups_emailAlert.id
