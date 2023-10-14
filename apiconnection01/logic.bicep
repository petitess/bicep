targetScope = 'resourceGroup'

param env string
param location string

var mailTo = 'support@b3care.se'
var aaName = 'aa-${env}-01'
var runbookName = 'run-TryStartVM01'

module rbac 'rbac.bicep' = {
  scope: subscription()
  name: 'module-${logic01.name}-rbac'
  params: {
    role: 'Reader'
    principalId: logic01.identity.principalId
  }
}

module rbac2 'rbac.bicep' = {
  scope: subscription()
  name: 'module-${logic04.name}-rbac'
  params: {
    role: 'Automation Contributor'
    principalId: logic04.identity.principalId
  }
}

resource managedId 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-id${env}01'
  location: location
  properties: {
    displayName: 'Managed identity for logic-runbook-${env}-01'
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureautomation')
    }
    parameterValueSet: {
      name: 'oauthMI'
      values: {}
    }
  }
}

resource office36501 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-office365${env}01'
  location: location
  properties: {
    ////You have to log in manually to an account in the azure portal to connect
    displayName: 'support@b3care.se'
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'office365')
    }
    customParameterValues: {}
    nonSecretParameterValues: {}
  }
}

resource defender 'Microsoft.Web/connections@2016-06-01' = {
  name: 'api-defender${env}01'
  location: location
  properties: {
    displayName: 'Microsoft Defender for Cloud Alert'
    customParameterValues: {}
    nonSecretParameterValues: {}
    api: {
      id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'ascalert')
    }
  }
}

resource logic01 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'logic-updatesummery-${env}-01'
  location: location
  tags: union(resourceGroup().tags, { Application: 'Resource Graph Query' })
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
            id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'office365')
          }
        } }
    }
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
        'Recurrence_-_once_every_day': {
          recurrence: {
            frequency: 'Week'
            interval: 1
            schedule: {
              hours: [
                '5'
              ]
              minutes: [
                30
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
        Condition: {
          actions: {
            Terminate: {
              runAfter: {}
              type: 'Terminate'
              inputs: {
                runStatus: 'Succeeded'
              }
            }
          }
          runAfter: {
            Parse_JSON: [
              'Succeeded'
            ]
          }
          else: {
            actions: {
              Create_CSV_table: {
                runAfter: {}
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
                      {
                        ContentBytes: '@{base64(body(\'Parse_JSON\'))}'
                        Name: 'UpdateSummery.json'
                      }
                    ]
                    Body: '<p>@{body(\'Create_HTML_table\')}</p>'
                    Importance: 'Normal'
                    Subject: 'Operations: Update Summery - B3Care'
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
          }
          expression: {
            and: [
              {
                equals: [
                  '@body(\'Parse_JSON\')?[\'count\']'
                  0
                ]
              }
            ]
          }
          type: 'If'
        }
        HTTP: {
          runAfter: {}
          type: 'Http'
          inputs: {
            authentication: {
              type: 'ManagedServiceIdentity'
            }
            body: {
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
                count: {}
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
                    required: []
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
                totalRecords: {}
              }
              type: 'object'
            }
          }
        }
      }
      outputs: {}
    }
  }
}

resource logic02 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'logic-defender-${env}-01'
  location: location
  tags: union(resourceGroup().tags, { Application: 'Defender for cloud' })
  properties: {
    state: 'Enabled'
    parameters: {
      '$connections': {
        value: {
          ascalert: {
            connectionId: defender.id
            connectionName: 'ascalert'
            id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'ascalert')
          }
          office365: {
            connectionId: office36501.id
            connectionName: 'office365'
            id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'office365')
          }
        }
      }
    }
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
        When_a_Microsoft_Defender_for_Cloud_alert_is_created_or_triggered: {
          type: 'ApiConnectionWebhook'
          inputs: {
            body: {
              callback_url: '@{listCallbackUrl()}'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'ascalert\'][\'connectionId\']'
              }
            }
            path: '/Microsoft.Security/Alert/subscribe'
          }
        }
      }
      actions: {
        Condition: {
          actions: {
            'Send_an_email_(V2)': {
              runAfter: {}
              type: 'ApiConnection'
              inputs: {
                body: {
                  Body: '<p>Alert Name: @{triggerBody()?[\'AlertDisplayName\']}<br>\nLink: @{triggerBody()?[\'AlertUri\']}<br>\nSeverity: @{triggerBody()?[\'Severity\']}<br>\nTime: @{triggerBody()?[\'TimeGenerated\']}</p>'
                  Importance: 'Normal'
                  Subject: 'B3Care: @{triggerBody()?[\'AlertDisplayName\']}'
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
          runAfter: {}
          else: {
            actions: {
              Terminate: {
                runAfter: {}
                type: 'Terminate'
                inputs: {
                  runStatus: 'Succeeded'
                }
              }
            }
          }
          expression: {
            and: [
              {
                equals: [
                  '@triggerBody()?[\'Severity\']'
                  'High'
                ]
              }
            ]
          }
          trackedProperties: {}
          type: 'If'
        }
      }
      outputs: {}
    }

  }
}

resource logic03 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'logic-defender-${env}-02'
  location: location
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
            id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'office365')
          }
        }
      }
    }
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
        'Recurrence_-_once_every_day': {
          recurrence: {
            frequency: 'Month'
            interval: 1
          }
          type: 'Recurrence'
        }
      }
      actions: {
        Condition: {
          actions: {
            Terminate: {
              runAfter: {}
              type: 'Terminate'
              inputs: {
                runStatus: 'Succeeded'
              }
            }
          }
          runAfter: {
            Parse_JSON: [
              'Succeeded'
            ]
          }
          else: {
            actions: {
              Create_CSV_table: {
                runAfter: {}
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
                        Name: 'VulnerabilityFindings.txt'
                      }
                      {
                        ContentBytes: '@{base64(body(\'Parse_JSON\'))}'
                        Name: 'VulnerabilityFindings.json'
                      }
                    ]
                    Body: '<p>@{body(\'Create_HTML_table\')}<br>\n<a href="https://portal.azure.com/#view/Microsoft_Azure_Security_R3/ServerVulnerabilityAssessmentRemediationDetailsBlade/assessmentKey/1195afff-c881-495e-9bc5-1486211ae03f/subscriptionIds~/%5B%229376fdb8-ba53-409c-b613-9118f13f6470%22%2C%220dcc13b7-1a10-483e-95aa-fe7e71802e2e%22%2C%22b2f0f1dc-be27-46a2-9bb0-e80270acfaa0%22%5D/showSecurityCenterCommandBar~/false/assessmentOwners~/null">Link to Vulnerability Findings</a></p>'
                    Importance: 'Normal'
                    Subject: 'Operations: Vulnerability Findings - B3Care'
                    To: 'support@b3care.se'
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
          }
          expression: {
            and: [
              {
                equals: [
                  '@body(\'Parse_JSON\')?[\'count\']'
                  0
                ]
              }
            ]
          }
          type: 'If'
        }
        HTTP: {
          runAfter: {}
          type: 'Http'
          inputs: {
            authentication: {
              type: 'ManagedServiceIdentity'
            }
            body: {
              query: 'securityresources | where type =~ \'microsoft.security/assessments/subassessments\' | extend assessmentKey=extract(@\'(?i)providers/Microsoft.Security/assessments/([^/]*)\', 1, id), subAssessmentId=tostring(properties.id), parentResourceId= extract(\'(.+)/providers/Microsoft.Security\', 1, id) | extend resourceId = tostring(properties.resourceDetails.id) | extend subAssessmentName=tostring(properties.displayName),subAssessmentCategory=tostring(properties.category),severity=tostring(properties.status.severity),status=tostring(properties.status.code),additionalData=tostring(properties.additionalData) | where assessmentKey == \'1195afff-c881-495e-9bc5-1486211ae03f\' | where status == \'Unhealthy\' | where  severity == \'High\' | summarize numOfResources=dcount(resourceId) by subAssessmentId, subAssessmentName, subAssessmentCategory, severity, status'
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
                  type: 'integer'
                }
                data: {
                  items: {
                    properties: {
                      assessmentKey: {
                        type: 'string'
                      }
                      high: {
                        type: 'integer'
                      }
                      numOfResources: {
                        type: 'integer'
                      }
                      severity: {
                        type: 'string'
                      }
                      status: {
                        type: 'string'
                      }
                      subAssessmentCategory: {
                        type: 'string'
                      }
                      subAssessmentDescription: {
                        type: 'string'
                      }
                      subAssessmentId: {
                        type: 'string'
                      }
                      subAssessmentName: {
                        type: 'string'
                      }
                      timeGenerated: {
                        type: 'string'
                      }
                    }
                    required: []
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
                  type: 'integer'
                }
              }
              type: 'object'
            }
          }
        }
      }
      outputs: {}
    }

  }
}

resource logic04 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'logic-runbook-${env}-01'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
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
        Recurrence: {
          type: 'Recurrence'
          recurrence: {
            frequency: 'Week'
            timeZone: 'W. Europe Standard Time'
            interval: 5
            schedule: {
              hours: [
                '8'
                '9'
                '10'
                '11'
                '12'
                '13'
                '14'
                '15'
              ]
              minutes: [
                0
                5
                10
                15
                20
                25
                30
                35
                40
                45
                50
                55
              ]
              weekDays: [
                'Monday'
                'Tuesday'
                'Wednesday'
                'Thursday'
                'Friday'
              ]
            }
          }
        }
      }
      actions: {
        Create_job: {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azureautomation\'][\'connectionId\']'
              }
            }
            method: 'put'
            path: '/subscriptions/@{encodeURIComponent(\'${subscription().subscriptionId}\')}/resourceGroups/@{encodeURIComponent(\'rg-${aaName}\')}/providers/Microsoft.Automation/automationAccounts/@{encodeURIComponent(\'${aaName}\')}/jobs'
            queries: {
              runbookName: runbookName
              wait: false
              'x-ms-api-version': '2015-10-31'
            }
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          azureautomation: {
            connectionId: managedId.id
            connectionName: 'azureautomation'
            id: extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureautomation')
            connectionProperties: {
              authentication: {
                type: 'ManagedServiceIdentity'
              }
            }
          }
        }
      }
    }
  }
}
