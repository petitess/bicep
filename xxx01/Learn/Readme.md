### ResourceId

#### resourcegroup scope:

resourceId('Microsoft.Compute/virtualMachines', VmName)

resourceId('Microsoft.Compute/availabilitySets', availabilitySetName)

resourceId('Microsoft.Compute/disks', diskName)

resourceId('Microsoft.OperationalInsights/workspaces', workspaceName)

resourceId(rgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, backendAddressPoolName)


#### subcription scope:

resourceId(subscription().subscriptionId, rgName, 'Microsoft.Storage/storageAccounts', stName)

resourceId(subscription().subscriptionId, rgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c

### uniqueString()



### environment()

environment().authentication.loginEndpoint == https://login.microsoftonline.com/

environment().suffixes.keyvaultDns == .vault.azure.net

### contains()

if(contains(param, 'vm'))

if (contains(VmName, 'web'))
