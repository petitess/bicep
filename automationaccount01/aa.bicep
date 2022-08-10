targetScope = 'resourceGroup'

param name string
param location string
param locatonalt string
param baseTime string = utcNow('u')

var tags = resourceGroup().tags
var startTime = dateTimeAdd(baseTime, 'PT1H') //Start time in one hour after deployment

resource aa 'Microsoft.Automation/automationAccounts@2021-06-22'  = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

resource runbook01 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  name: 'Runbook01'
  parent: aa
  location: location
  tags: tags
  properties: {
    runbookType:  'PowerShell'
    logVerbose: false
    logProgress: false
    logActivityTrace: 0
    description: 'Fileshare on-demand snapshot'
    publishContentLink: {
      uri: 'https://raw.githubusercontent.com/petitess/powershell/main/Azure/Remove-AzStorageBlob01.ps1'
    }
  }
}

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: name
  location: location
  tags: tags
}

module rbac 'rbac.bicep' = {
  scope: subscription()
  name: 'module-${name}-rbac01'
  params: {
    principalId: id.properties.principalId
  }
}

module rbac2 'rbac.bicep' = {
  scope: subscription()
  name: 'module-${name}-rbac02'
  params: {
    principalId: aa.identity.principalId
  }
}

resource script01 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'runbook-script02'
  location: locatonalt
  kind: 'AzurePowerShell'
  identity: {
     type: 'UserAssigned'
     userAssignedIdentities: {
      '${id.id}': {}
     }
  }
  properties: {
    azPowerShellVersion: '5.0'
    retentionInterval:  'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    environmentVariables: [
      {
        name: 'rgname'
        value: resourceGroup().name
      }
      {
        name: 'aaname'
        value: aa.name
      }
      {
        name: 'runbookname'
        value: 'Runbook02'
      }
    ]
    scriptContent: loadTextContent('script01.ps1')
}
}

resource sche 'Microsoft.Automation/automationAccounts/schedules@2020-01-13-preview' = {
  name: 'PS-schedule'
  parent: aa
  properties: {
    interval: '1'
    frequency: 'Day' 
    startTime: startTime
    timeZone: 'W. Europe Standard Time'
  }
}

resource jobSchedule1 'Microsoft.Automation/automationAccounts/jobSchedules@2020-01-13-preview' =  {
  name: guid(uniqueString(aa.id, '1'))
  parent: aa
  properties: {
   runbook:  {
     name: runbook01.name
   }
    schedule:  {
      name: sche.name
    }
  }
}

resource jobSchedule2 'Microsoft.Automation/automationAccounts/jobSchedules@2020-01-13-preview' =  {
  name: guid(uniqueString(aa.id, '2'))
  parent: aa
  dependsOn:  [
    script01
  ]
  properties: {
   runbook:  {
     name: 'Runbook02'
   }
    schedule:  {
      name: sche.name
    }
  }
}

