targetScope = 'resourceGroup'

param name string
param location string
param idId string

resource aa 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: name
  tags: resourceGroup().tags
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
    encryption: {
      keySource: 'Microsoft.Automation'
      identity: {}
    }
  }
}

module rbac 'rbac.bicep' = {
  scope: subscription()
  name: 'module-${name}-rbac'
  params: {
    principalId: aa.identity.principalId
    roles: [
      'Contributor'
    ]
  }
}

resource script01 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'ds-StopStartVM'
  location: location
  kind: 'AzurePowerShell'
  tags: {
    Application: 'Automation Account - Runbook'
    Service: aa.name
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${idId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '9.7'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    environmentVariables: [
      {
        name: 'infrargname'
        value: resourceGroup().name
      }
      {
        name: 'aaname'
        value: aa.name
      }
    ]
    scriptContent: loadTextContent('./run-StopStartVM01.ps1')
  }
}

output aaName string = aa.name
output aaId string = aa.id
