targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param idId string
param param object
param aaname string
param aargname string

resource script01 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'ADpassword-${name}'
  location: location
  kind: 'AzurePowerShell'
  tags: union(tags,
    {
    Application: 'Automation Account - Runbook'
    Service: aaname
    })
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${idId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '5.0'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    environmentVariables: [
      {
        name: 'infrargname'
        value: aargname
      }
      {
        name: 'aaname'
        value: aaname
      }
      {
        name: 'runbookname01'
        value: param.runbooks.adpassexp.runbookname
      }
    ]
    scriptContent: loadTextContent('./scripts/run-ADpass.ps1')
  }
}

output id string = script01.id
