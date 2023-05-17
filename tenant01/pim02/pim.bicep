param name string
param location string
param tags object = union(resourceGroup().tags, { Script: 'Privileged Identity Management' })

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-${name}'
  location: location
  tags: tags
}

resource scriptPIM 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
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
    azPowerShellVersion: '9.6'
    retentionInterval: 'PT1H'
    timeout: 'PT10M'
    cleanupPreference: 'Always'
    scriptContent: loadTextContent('./pim.ps1')
    environmentVariables: [
      {
        name: 'SubName'
        value: subscription().displayName
      }
    ]
  }
}

module rbac 'rbac.bicep' = {
  name: 'rbac_id'
  scope: subscription()
  params: {
    principalId: id.properties.principalId
    roles: ['Owner']
  }
}
