targetScope = 'resourceGroup' 

param env string
param location string
param staccountName string
param rginfraname string
param aaname string
param runbookname string
param tablename string
param clientId string
param clientSec string

var tags = union(resourceGroup().tags,{
  Application: 'AD Password Expiration'
})

resource logic 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'logic-${env}-01'
  location: location
  tags: tags
  properties: {
    state: 'Enabled'
    parameters: {
      '$connections': {
        value: {
          azureautomation: {
            connectionId: azureautomation01.id
            connectionName: 'azureautomation'
            id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureautomation')
          }
          
          azuretables: {
            connectionId: azuretables01.id
            connectionName: 'azuretables'
            id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azuretables')
          }
          office365: {
            connectionId: office36501.id
            connectionName: 'office365'
            id:  extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'office365')
          }
        }}}
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
                '8'
              ]
              minutes: [
                0
              ]
              weekDays: [
                'Monday'
                'Tuesday'
                'Wednesday'
                'Thursday'
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
                '8'
              ]
              minutes: [
                0
              ]
              weekDays: [
                'Monday'
                'Tuesday'
                'Wednesday'
                'Thursday'
                'Friday'
              ]
            }
            startTime: '2022-11-18T07:00:00Z'
          }
          type: 'Recurrence'
        }
      }
      actions: {
        Check_runbook_status: {
          actions: {
            Condition: {
              actions: {
              }
              runAfter: {
                For_each_verification_row_in_Table: [
                  'Succeeded'
                ]
              }
              expression: {
                and: [
                  {
                    equals: [
                      '@variables(\'Verificationrow\')'
                      'Success'
                    ]
                  }
                ]
              }
              type: 'If'
            }
            For_each_verification_row_in_Table: {
              foreach: '@body(\'Get_verification_row_in_Table\')?[\'value\']'
              actions: {
                Set_variable: {
                  runAfter: {
                  }
                  type: 'SetVariable'
                  inputs: {
                    name: 'Verificationrow'
                    value: '@{items(\'For_each_verification_row_in_Table\')?[\'ExpiryDate\']}'
                  }
                }
              }
              runAfter: {
                Get_verification_row_in_Table: [
                  'Succeeded'
                ]
              }
              type: 'Foreach'
              runtimeConfiguration: {
                concurrency: {
                  repetitions: 1
                }
              }
            }
            Get_verification_row_in_Table: {
              runAfter: {
              }
              type: 'ApiConnection'
              inputs: {
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'azuretables\'][\'connectionId\']'
                  }
                }
                method: 'get'
                path: '/Tables/@{encodeURIComponent(\'${tablename}\')}/entities'
                queries: {
                  '$filter': 'ExpiryDate eq \'Success\' and WriteTime eq \'@{outputs(\'Get_todays_date\')}\''
                }
              }
            }
          }
          runAfter: {
            Initialize_variable_Verificationrow: [
              'Succeeded'
            ]
          }
          expression: {
            and: [
              {
                equals: [
                  '@body(\'Start_Runbook\')?[\'properties\']?[\'status\']'
                  'Completed'
                ]
              }
            ]
          }
          type: 'If'
        }
        'For_each_-_Delete_verification_row': {
          foreach: '@body(\'Get_verification_row_in_Table\')?[\'value\']'
          actions: {
            Delete_verification_row: {
              runAfter: {
              }
              type: 'ApiConnection'
              inputs: {
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'azuretables\'][\'connectionId\']'
                  }
                }
                method: 'delete'
                path: '/Tables/@{encodeURIComponent(\'${tablename}\')}/entities/etag(PartitionKey=\'@{encodeURIComponent(items(\'For_each_-_Delete_verification_row\')?[\'PartitionKey\'])}\',RowKey=\'@{encodeURIComponent(items(\'For_each_-_Delete_verification_row\')?[\'RowKey\'])}\')'
              }
            }
          }
          runAfter: {
            For_each_row_in_Table: [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
        For_each_row_in_Table: {
          foreach: '@body(\'Get_Table\')?[\'value\']'
          actions: {
            Delete_row_in_table_when_email_sent: {
              runAfter: {
                'Send_an_email_(V2)': [
                  'Succeeded'
                ]
              }
              type: 'ApiConnection'
              inputs: {
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'azuretables\'][\'connectionId\']'
                  }
                }
                method: 'delete'
                path: '/Tables/@{encodeURIComponent(\'${tablename}\')}/entities/etag(PartitionKey=\'@{encodeURIComponent(items(\'For_each_row_in_Table\')?[\'PartitionKey\'])}\',RowKey=\'@{encodeURIComponent(items(\'For_each_row_in_Table\')?[\'RowKey\'])}\')'
              }
            }
            'Send_an_email_(V2)': {
              runAfter: {
              }
              type: 'ApiConnection'
              inputs: {
                body: {
                  Body: '<p>Hej!<br>\n<br>\nLösenordet för nedanstående konto kommer att gå ut @{items(\'For_each_row_in_Table\')?[\'ExpiryDate\']}<br>\nAnvändare: @{items(\'For_each_row_in_Table\')?[\'UserPrincipalName\']} (@{items(\'For_each_row_in_Table\')?[\'Name\']})<br>\n<br>\n- För att byta ditt lösenord på en Almidator, tryck på Ctrl+Alt+Delete på tangentbordet och välj Ändra lösenord.<br>\n- Om du inte har en Almidator, logga in på <a href="https://myaccount.microsoft.com/">https://myaccount.microsoft.com/</a> &nbsp;och välj Lösenord/byt Lösenord.<br>\n- Om du glömt ditt lösenord kan du återställa det genom att gå in på <a href="https://passwordreset.microsoftonline.com/">https://passwordreset.microsoftonline.com/</a> och följa instruktionerna.<br>\n<br>\n<u>Ditt nya lösenord måste uppfylla följande kriterier:</u><br>\n- Det måste bestå av minst 10 tecken (gärna längre)<br>\n- Lösenordet måste vara komplext, tex. innehålla tecken från tre av följande kategorier:<br>\n&nbsp;&nbsp;&nbsp;&nbsp;- Stora bokstäver (A till Z)<br>\n&nbsp;&nbsp;&nbsp;&nbsp;- Små bokstäver (a till z)<br>\n&nbsp;&nbsp;&nbsp;&nbsp;- Siffror (0 till 9)<br>\n&nbsp;&nbsp;&nbsp;&nbsp;- Icke alfanumeriska tecken (tex.:, !, $, #, %)<br>\n<br>\nFörsta gången efter lösenordsbytet, då du med Almidator ansluter till Remote desktop och "O: koncerngemensam" kommer du bli ombedd att ange dina uppgifter på nytt. Tryck då "fler alternativ" och välj ditt användarkonto samt skriv in det nya lösenordet.<br>\n<br>\nVid problem eller frågor kontakta B3 Servicedesk på:<br>\n<br>\nTelefon: 010-2348110<br>\nMail: support.almi@b3.se<br>\nÖppettider: Vardagar 07.00 - 18.00<br>\n<br>\nMed vänliga hälsningar<br>\nAlmi</p>'
                  Importance: 'High'
                  Subject: 'Ditt lösenord håller på att gå ut'
                  To: ' @{items(\'For_each_row_in_Table\')?[\'Mail\']}'
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
          runAfter: {
            Get_Table: [
              'Succeeded'
            ]
          }
          type: 'Foreach'
          runtimeConfiguration: {
            concurrency: {
              repetitions: 1
            }
          }
        }
        Get_Table: {
          runAfter: {
            Check_runbook_status: [
              'Succeeded'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuretables\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/Tables/@{encodeURIComponent(\'${tablename}\')}/entities'
            queries: {
              '$filter': 'ExpiryDate ne \'Success\''
            }
          }
        }
        Get_todays_date: {
          runAfter: {
            Start_Runbook: [
              'Succeeded'
            ]
          }
          type: 'Compose'
          inputs: '@utcnow(\'yyyyMMdd\')'
        }
        Initialize_variable_Verificationrow: {
          runAfter: {
            Get_todays_date: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Verificationrow'
                type: 'string'
              }
            ]
          }
        }
        Start_Runbook: {
          runAfter: {
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azureautomation\'][\'connectionId\']'
              }
            }
            method: 'put'
            path: '/subscriptions/@{encodeURIComponent(\'${subscription().subscriptionId}\')}/resourceGroups/@{encodeURIComponent(\'${rginfraname}\')}/providers/Microsoft.Automation/automationAccounts/@{encodeURIComponent(\'${aaname}\')}/jobs'
            queries: {
              runbookName: runbookname
              wait: true
              'x-ms-api-version': '2022-08-08'
            }
          }
        }
      }
      outputs: {}
    }
  }
}

resource st01 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: staccountName
  scope: resourceGroup(rginfraname)
}

resource azuretables01 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-azuretables${env}01'
  location: location
  properties: {
    displayName: 'azuretable'
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azuretables')
    }
    parameterValues: {
      storageaccount: staccountName
      sharedkey: st01.listKeys().keys[0].value
    }
  }
}


resource azureautomation01 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-azureautomation${env}01'
  location: location
  properties: {
    displayName: 'azureautomation'
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureautomation')
    }
    parameterValues: {
      ////App registration client ID/secret with contributor access to manage automation account
      'token:clientId': clientId
      'token:clientSecret':clientSec
      'token:TenantId': empty(tenant().tenantId) ? tenant().tenantId : tenant().tenantId
      'token:grantType': 'client_credentials'
    }
  }
}

resource office36501 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-office365${env}01'
  location: location
  properties: {
    ////You have to log in manually to an account in the azure portal to connect
    displayName: 'passwordreminder@company.net'
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'office365')
    }
    customParameterValues: {}
    nonSecretParameterValues: {}
  }
}
