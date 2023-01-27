targetScope = 'resourceGroup'

var policyAssignments = [
  {
    name: 'NotAllowedResourceTypesRgInfra'
    description: 'Restrict VMs to be deployed in infra resource group.'
    policyDefinition: '/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749'
    enforcementMode: 'Default'
    message: 'Resource not allowed by policy in this resource group.'
    parameters: {
      listOfResourceTypesNotAllowed: {
        value: [
          'Microsoft.Compute/availabilitySets'
          'Microsoft.Compute/virtualMachines'
          'Microsoft.Compute/virtualMachines/extensions'
          'Microsoft.Compute/virtualMachineScaleSets'
          'Microsoft.Compute/virtualMachineScaleSets/extensions'
          'Microsoft.Compute/virtualMachineScaleSets/virtualMachines'
          'Microsoft.Compute/virtualMachineScaleSets/virtualMachines/extensions'
          'Microsoft.Compute/virtualMachineScaleSets/networkInterfaces'
          'Microsoft.Compute/virtualMachineScaleSets/virtualMachines/networkInterfaces'
          'Microsoft.Compute/virtualMachineScaleSets/publicIPAddresses'
          'Microsoft.Compute/virtualMachines/runCommands'
          'Microsoft.Compute/virtualMachineScaleSets/applications'
          'Microsoft.Compute/virtualMachines/applications'
          'Microsoft.Compute/disks'
        ]
      }
     }
  }
]

resource policy01 'Microsoft.Authorization/policyAssignments@2022-06-01' = [for policyAssignment in policyAssignments: {
  name: policyAssignment.name
  properties: {
   description: policyAssignment.description
   policyDefinitionId: empty(policyAssignment) ? policyAssignment.policyDefinition : policyAssignment.policyDefinition
   enforcementMode: policyAssignment.enforcementMode
   nonComplianceMessages: [
     {
       message: policyAssignment.message
     }
   ]
   parameters: policyAssignment.parameters
  }
}]
