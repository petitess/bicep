param location string
param tags object = resourceGroup().tags
param affix string
param appGroups array
param managedIds array

var groups = [for group in appGroups: {
  name: group
}]

//Assign Groups Administator and Owner to this identity
resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: 'id-script-${affix}-01'
  location: location
  tags: tags
}

resource script 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'script-${affix}-03'
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${id.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '9.7'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    scriptContent: loadTextContent('./rbac.ps1')
    environmentVariables: [
      {
        name: 'Groups'
        value: string(groups)
      }
      {
        name: 'ManagedId'
        value: string(managedIds)
      }
    ]
  }
}

output groups array = [for grp in groups: {
  name : 'grp-rbac-${grp.name}'
  objectId: script.properties.outputs['grp-rbac-${grp.name}']
}]



