targetScope = 'resourceGroup'

param name string
param location string
param tags object = resourceGroup().tags
param idId string
param aaName string
param aaRgName string

resource script01 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: name
  location: location
  kind: 'AzurePowerShell'
  tags: union(
    tags,
    {
      Application: 'Automation Account - Runbook'
      Service: aaName
    }
  )
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${idId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '11.4'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    environmentVariables: [
      {
        name: 'infrargname'
        value: aaRgName
      }
      {
        name: 'aaname'
        value: aaName
      }
    ]
    scriptContent: loadTextContent('./scripts/run-ADpass.ps1')
  }
}

output id string = script01.id
