targetScope = 'resourceGroup'

param roleDefinitionId01 string 
param roleDefinitionId03 string 
param idname string
param idscope string
param name string
param location string
//param guidValue string = newGuid()
param baseTime string = utcNow('u')

var tags = resourceGroup().tags
var startTime = dateTimeAdd(baseTime, 'PT1H') //Start time in one hour after deployment

//If you use 'UserAssigned' identity. You need to create a user assigned identity. I already have one from previous deployment.
resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(idscope)
  name: idname
}

//If you use 'SystemAssigned' idenity. You need to create a role assigment.
//First role assigment is assigned to a resource group:
resource roleassigment01 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(roleDefinitionId01, resourceGroup().id)
  properties: {
    principalId: AA.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId01)
    principalType: 'ServicePrincipal'
  }
}
resource sub 'Microsoft.Subscription/aliases@2021-10-01' existing =  {
  name: 'Azure subscription 1'
  scope: tenant()
}
//Second role assigment is assigned to a subscription:
resource roleassigment02 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(roleDefinitionId03, resourceGroup().id)
  scope: sub
  properties: {
    principalId: AA.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId03)
    principalType:   'ServicePrincipal'
  }
}

//Create an automation account
resource AA 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: name
  location: location
  tags: tags
  //You can choose 'SystemAssigned' or 'UserAssigned'. Dont need both.
  identity: {
  type:  'SystemAssigned, UserAssigned'
  //You can remove "userAssignedIdentities" property if you use "SystemAssigned" identity
  userAssignedIdentities: {
      '${id.id}': {}
  }
}
properties: {
  sku: {
    name:  'Free'
  }
  encryption: {
    keySource: 'Microsoft.Automation'
    identity: {
    }
  }
}
}
//Create a runbook which will get a powershell script from github
resource AAPS 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  name: 'Powershell01'
  parent: AA
  location: location 
  properties: {
    runbookType:  'PowerShell' 
    publishContentLink: {
       uri: 'https://raw.githubusercontent.com/petitess/powershell/main/Azure/runbook-test.ps1'
    }
  }
}
//Create a schedule
resource AASCH 'Microsoft.Automation/automationAccounts/schedules@2020-01-13-preview' = {
  name: 'PS-schedule'
  parent: AA
  properties: {
    interval: '1'
    frequency: 'Day' 
    startTime: startTime
    timeZone: 'W. Europe Standard Time'
  }
}

/*
//USE POWERSHELL SCRIPT INSTEAD
//Link the schedule with runbook
resource AAJOBSCH 'Microsoft.Automation/automationAccounts/jobSchedules@2019-06-01' =  {
  name: guidValue
  parent: AA 
  properties: {
   runbook:  {
     name: AAPS.name
   }
   
    schedule:  {
      name: AASCH.name
    }
  }
}*/

output AAname string = AA.name

