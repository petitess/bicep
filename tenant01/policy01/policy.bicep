targetScope = 'managementGroup'

param managementGroupName string

var policyAssignments = [
  {
    name: 'AllowedResourceTypes'
    description: 'This policy enables you to specify the resource types that your organization can deploy. Only resource types that support tags and location will be affected by this policy. To restrict all resources please duplicate this policy and change the "mode" to All'
    policyDefinition: 'a08ec900-254a-4555-9bf5-e42af04b5c5c'
    enforcementMode: 'Default'
    message: 'Resource not allowed by policy'
    parameters: {
      listOfResourceTypesAllowed: {
        value: [
        'Microsoft.Resources/deployments'
        'Microsoft.Resources/resourceGroups'
        'Microsoft.Automation/automationAccounts'
        'Microsoft.Automation/automationAccounts/runbooks'
        'Microsoft.Automation/automationAccounts/jobSchedules'
        'Microsoft.Automation/automationAccounts/schedules'
        'Microsoft.Automation/automationAccounts/jobs'
        'Microsoft.Automation/automationAccounts/connectionTypes'
        'Microsoft.Automation/automationAccounts/modules'
        'Microsoft.Insights/actionGroups'
        'Microsoft.Insights/activityLogAlerts'
        'Microsoft.Compute/availabilitySets'
        'Microsoft.Network/bastionHosts'
        'Microsoft.Insights/dataCollectionRules'
        'Microsoft.Insights/diagnosticSettings'
        'Microsoft.ManagedIdentity/userAssignedIdentities'
        'Microsoft.KeyVault/vaults'
        'Microsoft.KeyVault/vaults/secrets'
        'Microsoft.Maintenance/maintenanceConfigurations'
        'Microsoft.Network/networkWatchers'
        'Microsoft.Network/networkWatchers/connectionMonitors'
        'Microsoft.Insights/metricAlerts'
        'Microsoft.Network/privateEndpoints'
        'Microsoft.Authorization/roleAssignments'
        'Microsoft.RecoveryServices/vaults'
        'Microsoft.RecoveryServices/vaults/backupPolicies'
        'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems'
        'Microsoft.ManagedIdentity/userAssignedIdentities'
        'Microsoft.Resources/deploymentScripts'
        'Microsoft.Resources/deploymentScripts/logs'
        'Microsoft.Storage/storageAccounts'
        'Microsoft.Storage/storageAccounts/fileServices'
        'Microsoft.Storage/storageAccounts/fileServices/shares'
        'Microsoft.Storage/storageAccounts/blobServices'
        'Microsoft.Storage/storageAccounts/blobServices/containers'
        'Microsoft.Storage/storageAccounts/queueServices'
        'Microsoft.Storage/storageAccounts/queueServices/queues'
        'Microsoft.Storage/storageAccounts/tableServices'
        'Microsoft.Storage/storageAccounts/tableServices/tables'
        'Microsoft.Network/publicIPAddresses'
        'Microsoft.Network/virtualNetworkGateways'
        'Microsoft.Network/localNetworkGateways'
        'Microsoft.Network/connections'
        'Microsoft.Compute/virtualMachines'
        'Microsoft.Compute/disks'
        'Microsoft.Network/networkInterfaces'
        'Microsoft.Compute/virtualMachines/extensions'
        'Microsoft.Insights/dataCollectionRuleAssociations'
        'Microsoft.Maintenance/configurationAssignments'
        'Microsoft.Insights/scheduledQueryRules'
        'Microsoft.OperationalInsights/workspaces'
        'Microsoft.OperationalInsights/workspaces/dataSources'
        'Microsoft.OperationsManagement/solutions'
        'Microsoft.OperationalInsights/workspaces/linkedServices'
        'Microsoft.Network/virtualNetworks'
        'Microsoft.Network/networkSecurityGroups'
        'Microsoft.Network/routeTables'
        'Microsoft.Network/natGateways'
        'Microsoft.Network/virtualNetworks/virtualNetworkPeerings'
        'Microsoft.ManagedIdentity/identities'
        'Microsoft.ManagedIdentity/userAssignedIdentities'
        'Microsoft.ContainerInstance/containerGroups'
        'Microsoft.Compute/restorePointCollections'
        ]
      }
     }
  }
  {
    name: 'AllowedVmSizeSKUs'
    description: 'This policy enables you to specify a set of virtual machine size SKUs that your organization can deploy.'
    policyDefinition: 'cccc23c7-8427-4f53-ad12-b6a63eb452b3'
    enforcementMode: 'Default'
    message: 'Virtual machine size SKU not allowed'
    parameters: {
      listOfAllowedSKUs: {
        value: [
          'standard_b1s'
          'standard_b1ms'
          'standard_b2s'
        ]
      }
     }
  }
]


resource policy01 'Microsoft.Authorization/policyAssignments@2022-06-01' = [for policyAssignment in policyAssignments: {
  name: policyAssignment.name
  properties: {
   description: 'This policy enables you to specify the resource types that your organization can deploy. Only resource types that support tags and location will be affected by this policy. To restrict all resources please duplicate this policy and change the "mode" to All'
   displayName: 'AzurePolicyAssignment-${managementGroupName}-${policyAssignment.name}'
   policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', policyAssignment.policyDefinition)
   enforcementMode: policyAssignment.enforcementMode
   nonComplianceMessages: [
     {
       message: policyAssignment.message
     }
   ]
   parameters: policyAssignment.parameters
  }
}]
