targetScope = 'resourceGroup' 

param env string
param location string

var tags = resourceGroup().tags

var subId = subscription().subscriptionId
var mailTo = 'name@mail.se'

resource office36501 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-office365${env}01'
  location: location
  properties: {
    ////You have to log in manually to an account in the azure portal to connect
    displayName: 'support@mail.se'
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'office365')
    }
    customParameterValues: {}
    nonSecretParameterValues: {}
  }
}

resource logic 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'logic-updatesummery-${env}-01'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    parameters: {
      '$connections': {
        value: {
          office365: {
            connectionId: office36501.id
            connectionName: 'office365'
            id:  extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'office365')
          }
        }}
      }
      definition: {
        '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
        contentVersion: '1.0.0.0'
        parameters: {
          '$connections': {
            defaultValue: {
            }
            type: 'Object'
          }
        }
        triggers: {
          'Recurrence_-_once_every_day': {
            recurrence: {
              frequency: 'Week'
              interval: 1
              schedule: {
                hours: [
                  '7'
                ]
                minutes: [
                  0
                ]
                weekDays: [
                  'Friday'
                ]
              }
              startTime: '2022-11-18T07:00:00Z'
            }
            evaluatedRecurrence: {
              frequency: 'Week'
              interval: 1
              schedule: {
                hours: [
                  '7'
                ]
                minutes: [
                  0
                ]
                weekDays: [
                  'Friday'
                ]
              }
              startTime: '2022-11-18T07:00:00Z'
            }
            type: 'Recurrence'
          }
        }
        actions: {
          Create_CSV_table: {
            runAfter: {
              Parse_JSON: [
                'Succeeded'
              ]
            }
            type: 'Table'
            inputs: {
              format: 'CSV'
              from: '@body(\'Parse_JSON\')?[\'data\']'
            }
          }
          Create_HTML_table: {
            runAfter: {
              Create_CSV_table: [
                'Succeeded'
              ]
            }
            type: 'Table'
            inputs: {
              format: 'HTML'
              from: '@body(\'Parse_JSON\')?[\'data\']'
            }
          }
          HTTP: {
            runAfter: {
            }
            type: 'Http'
            inputs: {
              authentication: {
                type: 'ManagedServiceIdentity'
              }
              body: {
                //query: 'patchassessmentresources | where type == \'microsoft.compute/virtualmachines/patchassessmentresults\' | where subscriptionId == \'${subId}\' | where properties.availablePatchCountByClassification.security > 0 or properties.availablePatchCountByClassification.critical > 0 | extend security = properties.availablePatchCountByClassification.security, critical = properties.availablePatchCountByClassification.critical | project resourceGroup, security, critical, vm =(replace(\'/subscriptions/${subId}/resourceGroups/*\', \'\', (trim_end(\'/patchAssessmentResults/latest\', id))))'
                query: 'patchassessmentresources | where type == \'microsoft.compute/virtualmachines/patchassessmentresults\' | where subscriptionId == \'${subscription().subscriptionId}\' | where properties.availablePatchCountByClassification.security > 0 or properties.availablePatchCountByClassification.critical > 0 | extend security = properties.availablePatchCountByClassification.security, critical = properties.availablePatchCountByClassification.critical | project vm = replace(\'/providers/Microsoft.Compute/virtualMachines\', \'\',(trim_end(\'/patchAssessmentResults/latest\', substring(id, 67, 150)))), security, critical'
                }
              headers: {
                'Content-Type': 'application/json'
              }
              method: 'POST'
              queries: {
                'api-version': '2021-03-01'
              }
              uri: '${environment().resourceManager}providers/Microsoft.ResourceGraph/resources'
            }
          }
          Parse_JSON: {
            runAfter: {
              HTTP: [
                'Succeeded'
              ]
            }
            type: 'ParseJson'
            inputs: {
              content: '@body(\'HTTP\')'
              schema: {
                properties: {
                  count: {
                  }
                  data: {
                    items: {
                      properties: {
                        critical: {}
                        resourceGroup: {
                          type: 'string'
                        }
                        security: {}
                        vm: {}
                      }
                      required: [
                        //'resourceGroup'
                        //'security'
                        //'critical'
                        //'vm'
                      ]
                      type: 'object'
                    }
                    type: 'array'
                  }
                  facets: {
                    type: 'array'
                  }
                  resultTruncated: {
                    type: 'string'
                  }
                  totalRecords: {
                  }
                }
                type: 'object'
              }
            }
          }
          'Send_an_email_(V2)': {
            runAfter: {
              Create_HTML_table: [
                'Succeeded'
              ]
            }
            type: 'ApiConnection'
            inputs: {
              body: {
                Attachments: [
                  {
                    ContentBytes: '@{base64(body(\'Create_CSV_table\'))}'
                    Name: 'UpdateSummery.txt'
                  }
                ]
                Body: '<p>@{body(\'Create_HTML_table\')}</p>'
                Importance: 'Normal'
                Subject: 'Operations: Update Summery'
                To: mailTo
              }
              host: {
                connection: {
                  name: '@parameters(\'$connections\')[\'office365\'][\'connectionId\']'
                }
              }
              method: 'post'
              path: '/v2/Mail'
            }
          }
        }
        outputs: {
        }
      }
  }
}

/*A sample JSON payload for Parse Json function:
{
  "totalRecords":null,
  "count":null,
  "data":[
  {"resourceGroup":"rg-vmmonprod01","security":null,"critical":null}
  ],"facets":[],
  "resultTruncated":"false"
  }
*/

output pricipalId string = logic.identity.principalId
