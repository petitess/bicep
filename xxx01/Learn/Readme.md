### ResourceId

#### resourcegroup scope:
```bicep
resourceId('Microsoft.Compute/virtualMachines', VmName)

resourceId('Microsoft.Compute/availabilitySets', availabilitySetName)

resourceId('Microsoft.Compute/disks', diskName)

resourceId('Microsoft.OperationalInsights/workspaces', workspaceName)

resourceId(rgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, backendAddressPoolName)
```

#### subcription scope:
```bicep
resourceId(subscription().subscriptionId, rgName, 'Microsoft.Storage/storageAccounts', stName)

resourceId(subscription().subscriptionId, rgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)

subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c
```
### uniqueString()
```bicep


### environment()
```bicep
environment().authentication.loginEndpoint == https://login.microsoftonline.com/

environment().suffixes.keyvaultDns == .vault.azure.net
```
### contains()
```bicep
if(contains(param, 'vm'))

if (contains(VmName, 'web'))
```
