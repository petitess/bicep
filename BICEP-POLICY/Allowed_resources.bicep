targetScope = 'subscription'

resource policy01 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: 'Test-Bicep'
  properties: {
   description: 'Allowed resource types'
   displayName: 'Allowed-res-bicep-policy' 
   policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/a08ec900-254a-4555-9bf5-e42af04b5c5c'
   enforcementMode: 'DoNotEnforce'
   nonComplianceMessages: [
     {
       message: 'Resource not allowed by policy'
     }
   ]
   parameters: {
    listOfResourceTypesAllowed: {
      value: [
        'Microsoft.Compute/disks'
        'Microsoft.Compute/locations'
        'Microsoft.Compute/locations/vmSizes'
        'Microsoft.Compute/locations/virtualMachines'
        'Microsoft.Compute/locations/virtualMachineScaleSets'
        'Microsoft.Compute/virtualMachines'
        'Microsoft.Compute/virtualMachines/extensions'
        'Microsoft.Compute/virtualMachines/metricDefinitions'
        'Microsoft.Compute/virtualMachines/runCommands'
        'Microsoft.Compute/virtualMachineScaleSets'
        'Microsoft.Compute/virtualMachineScaleSets/virtualMachines/extensions'
        'Microsoft.Compute/virtualMachineScaleSets/virtualMachines/networkInterfaces'
        'Microsoft.Compute/virtualMachineScaleSets/virtualMachines/runCommands'
        'Microsoft.Network/networkWatchers'
        'Microsoft.Network/networkSecurityGroups'
        'Microsoft.Network/networkSecurityGroups/securityRules'
        'Microsoft.Network/networkInterfaces'
        'Microsoft.Network/networkInterfaces/tapConfigurations'
        'Microsoft.Network/routeTables'
        'Microsoft.Network/virtualNetworks'
        'Microsoft.Storage/storageAccounts'
        

      ]
    }
   }

  }
}
