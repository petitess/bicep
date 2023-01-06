targetScope = 'resourceGroup'

param name string
param location string
param param object
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
    role1: param.id.contributor
    role2: param.id.reader
    principalId: aa.identity.principalId
  }
}


resource script01 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'StopStartVM'
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
    azPowerShellVersion: '5.0'
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
      {
        name: 'runbookname01'
        value: param.runbooks.stopstartvm.runbookname01
      }
      {
        name: 'runbookname02'
        value: param.runbooks.stopstartvm.runbookname02
      }
      {
        name: 'runbookname03'
        value: param.runbooks.stopstartvm.runbookname03
      }
      {
        name: 'runbookname04'
        value: param.runbooks.stopstartvm.runbookname04
      }
      {
        name: 'schedulename01'
        value: replace(param.runbooks.stopstartvm.runbookname01, 'run', 'sch')
      }
      {
        name: 'schedulename02'
        value: replace(param.runbooks.stopstartvm.runbookname02, 'run', 'sch')
      }
      {
        name: 'schedulename03'
        value: replace(param.runbooks.stopstartvm.runbookname03, 'run', 'sch')
      }
      {
        name: 'schedulename04'
        value: replace(param.runbooks.stopstartvm.runbookname04, 'run', 'sch')
      }
      {
        name: 'stopvmtime'
        value: param.runbooks.stopstartvm.stopvmtime
      }
      {
        name: 'startvmtime'
        value: param.runbooks.stopstartvm.startvmtime
      }
    ]
    scriptContent: loadTextContent('./run-StopStartVM01.ps1')
  }
}

output aaName string = aa.name
output aaId string = aa.id
