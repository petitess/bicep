targetScope = 'resourceGroup'

param location string
param affix object
param kvName string
param virtualMachines array

var tags = resourceGroup().tags
var vm = [for vm in virtualMachines: {
  name: vm.name
}]

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup('rg-kv-${affix.environmentLocation}-01')
  name: 'id-script-${affix.environmentLocation}-01'
}

resource secret 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'secret'
  location: location
  tags: tags
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${id.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '5.0'
    retentionInterval: 'PT1H'
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

output secretId string = secret.id
output secretApi string = secret.apiVersion
output adminUsername string = secret.properties.outputs.adminUsername
