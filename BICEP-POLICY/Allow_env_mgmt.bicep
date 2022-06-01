targetScope = 'managementGroup'

var subid = 'subscriptions/2d9f44ea-e3df-4ea1-b956-xxxxxxx'
var excluderg = 'Automation01'

resource policy01 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: 'Alllow-res-Bicep'
  scope: managementGroup()
  properties: {
   description: 'Allowed resource types'
   displayName: 'Allowed-resources-mgmt-policy' 
   policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/a08ec900-254a-4555-9bf5-e42af04b5c5c'
   enforcementMode: 'Default'
   notScopes: [
    '/${subid}/resourceGroups/${excluderg}'  
    ]
   metadata: {
     version: '0.1'
     category: 'subscription policy'
   }
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
        'Microsoft.Network/publicIPAddresses'
        'Microsoft.Network/routeTables'
        'Microsoft.Network/natGateways'
        'Microsoft.Network/bastionHosts'
        'Microsoft.Network/privateEndpoints'
        'Microsoft.Network/virtualNetworkGateways'
        'Microsoft.Storage/storageAccounts'
        'Microsoft.Storage/storageAccounts/fileServices'
        'Microsoft.KeyVault/vaults'
        'Microsoft.KeyVault/vaults/keys'
        'Microsoft.KeyVault/vaults/secrets'
        'Microsoft.ManagedIdentity/userAssignedIdentities'
        'Microsoft.Automation/automationAccounts'
        'Microsoft.Automation/automationAccounts/runbooks'
        'Microsoft.Automation/automationAccounts/schedules'
        'Microsoft.Automation/automationAccounts/jobSchedules'
        'Microsoft.Automation/automationAccounts/softwareUpdateConfigurations'
        'Microsoft.Resources/deploymentScripts'
        'Microsoft.Insights/diagnosticSettings'
        'Microsoft.Insights/actionGroups'
        'Microsoft.Insights/scheduledqueryrules'
        'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems'
        'Microsoft.OperationalInsights/workspaces'
        'Microsoft.OperationalInsights/workspaces/dataSources'
        'Microsoft.OperationalInsights/workspaces/linkedServices'
        'Microsoft.OperationsManagement/solutions'
        'Microsoft.RecoveryServices/vaults'
        'Microsoft.RecoveryServices/vaults/backupPolicies'


      ]
    }
   }

  }
}

