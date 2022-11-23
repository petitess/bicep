param prefix string
param location string = resourceGroup().location
param sendGridApiKey string

resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-11-01' existing = {
  name: '${prefix}sb'
}

resource serviceBusConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: '${prefix}sbconn'
  location: location
  properties: {
    displayName: '${prefix}sb'
    api: {
      id: '${subscription().id}/providers/Microsoft.Web/locations/${location}/managedApis/servicebus'
    }
    parameterValueSet: {
      name: 'managedIdentityAuth'
      values: {
        namespaceEndpoint: {
          value: 'sb://${serviceBus.name}.servicebus.windows.net'
        }
      }
    }
  }
}

resource sendGridConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: '${prefix}sndgrdconn'
  location: location
  properties: {
    displayName: '${prefix}sndgrdconn'
    api: {
      id: '${subscription().id}/providers/Microsoft.Web/locations/${location}/managedApis/sendgrid'
    }
    parameterValues: {
      apiKey: sendGridApiKey
    }
  }
}

resource logicAppEmailSend 'Microsoft.Logic/workflows@2019-05-01' = {
  name: '${prefix}logic-EmailSend'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        'When_a_message_is_received_in_a_queue_(auto-complete)': {
          recurrence: {
            frequency: 'Minute'
            interval: 3
          }
          evaluatedRecurrence: {
            frequency: 'Minute'
            interval: 3
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'servicebus\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/@{encodeURIComponent(encodeURIComponent(\'emailsend\'))}/messages/head'
            queries: {
              queueType: 'Main'
            }
          }
        }
      }
      actions: {
        'Dead-letter_the_message_in_a_queue': {
          runAfter: {
            Send_email: [
              'Failed'
              'TimedOut'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'servicebus\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/@{encodeURIComponent(encodeURIComponent(\'emailsend\'))}/messages/deadletter'
            queries: {
              deadLetterErrorDescription: ''
              deadLetterReason: ''
              lockToken: '@triggerBody()?[\'LockToken\']'
              sessionId: '@triggerBody()?[\'SessionId\']'
            }
          }
        }
        Parse_message: {
          runAfter: {}
          type: 'ParseJson'
          inputs: {
            content: '@base64ToString(triggerBody()?[\'ContentData\'])'
            schema: {
              properties: {
                body: {
                  type: 'string'
                }
                subject: {
                  type: 'string'
                }
                to: {
                  type: 'string'
                }
              }
              type: 'object'
            }
          }
        }
        Send_email: {
          runAfter: {
            Parse_message: [
              'Succeeded'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            body: {
              from: 'someone@somewhere.com'
              fromname: 'Someone'
              ishtml: true
              subject: '@body(\'Parse_message\')?[\'subject\']'
              text: '<p>@{body(\'Parse_message\')?[\'body\']}</p>'
              to: '@body(\'Parse_message\')?[\'to\']'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'sendgrid\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/v4/mail/send'
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          sendgrid: {
            connectionId: sendGridConnection.id
            connectionName: sendGridConnection.name
            id: '${subscription().id}/providers/Microsoft.Web/locations/${location}/managedApis/sendgrid'
          }
          servicebus: {
            connectionId: serviceBusConnection.id
            connectionName: serviceBusConnection.name
            connectionProperties: {
              authentication: {
                type: 'ManagedServiceIdentity'
              }
            }
            id: '${subscription().id}/providers/Microsoft.Web/locations/${location}/managedApis/servicebus'
          }
        }
      }
    }
  }
}
