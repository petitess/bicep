targetScope = 'resourceGroup'

param automationAccountId string
param webhookResourceId string
param webhookResourceUrl string

var location = 'global'
var tags = resourceGroup().tags
var emailReceivers = [
  {
    name: 'A3 Servicedesk-EmailAction'
    emailAddress: 'support@a3.se'
    useCommonAlertSchema: false
  }
]
var webhooks = [
  {
    name: 'A3-P3-Bas'
    shortName: 'P3-Bas'
    enabled: true
    webhookReceivers: [
      {
        name: 'A3BasWebhook'
        serviceUri: 'https://api.eu.opsgenie.com/v1/json/azure?apiKey=xxxxxxxxxxxxxxxxxxx'
        useCommonAlertSchema: true
        useAadAuth: false
      }
    ]
  }
  {
    name: 'A3-P5-Bas'
    shortName: 'P5-Bas'
    enabled: true
    webhookReceivers: [
      {
        name: 'P5BasWebhook'
        serviceUri: 'https://api.eu.opsgenie.com/v1/json/azure?apiKey=xxxxxxxxxxxxxxxxxxx'
        useCommonAlertSchema: true
        useAadAuth: false
      }
    ]
  }
]

resource actionGroups_emailAlert 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'A3 Support Email Alert'
  location: location
  tags: tags
  properties: {
    groupShortName: 'EmailAlert'
    enabled: true
    emailReceivers: emailReceivers
  }
}

resource actionGroupRestartGtm 'Microsoft.Insights/actionGroups@2024-10-01-preview' = {
  name: 'restart-gtm'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    groupShortName: 'restart-gtm'
    automationRunbookReceivers: [
      {
        name: 'restart-gtm'
        serviceUri: webhookResourceUrl
        automationAccountId: automationAccountId
        isGlobalRunbook: false
        runbookName: 'run-restart-app-gtm'
        webhookResourceId: webhookResourceId
        useCommonAlertSchema: true
      }
    ]
  }
}

resource actionGroups_webhookAlert 'Microsoft.Insights/actionGroups@2023-01-01' = [
  for webhook in webhooks: {
    name: webhook.name
    location: location
    tags: tags
    properties: {
      groupShortName: webhook.shortName
      enabled: webhook.enabled
      webhookReceivers: webhook.webhookReceivers
    }
  }
]

output actionGroupP3Bas string = actionGroups_webhookAlert[0].id
output actionGroupP5Bas string = actionGroups_webhookAlert[1].id
output ActionGroupEmail string = actionGroups_emailAlert.id
output actionGroupRestartGtm string = actionGroupRestartGtm.id
output actionGroupRestartGtmPrinciplaId string = actionGroupRestartGtm.identity.principalId
