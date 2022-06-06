targetScope = 'resourceGroup'

param name string
param location string
param idName string
param kvName string
param virtualMachines array

var tags = resourceGroup().tags
var vm = [for vm in virtualMachines: {
  name: vm.name
}] 

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' existing = {
  name: idName
}

resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  tags: tags
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${id.id}' :{}
    }
  }
  properties: {
    azPowerShellVersion: '5.0'
    retentionInterval:  'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    scriptContent: loadTextContent('secret.ps1') 
    environmentVariables: [
      {
        name: 'KeyVault'
        value: kvName
      }
      {
        name: 'VirtualMachines'
        value: string(vm)
      }
    ] 
  }
}
