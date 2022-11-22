resourceId(vnetrg, 'Microsoft.Network/virtualNetworks/subnets', vnetname, interface.subnet)

resourceId('Microsoft.Compute/disks', '${name}-${dataDisk.name}')

output a string = 'subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/azureblob'
output b string = extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureblob')

resourceId(sharedImageGalleryResourceGroup, 'Microsoft.Compute/galleries/images/versions', sharedImageGalleryName, sharedImageGalleryDefinitionname, sharedImageGalleryVersionName)
'/subscriptions/${sharedImageGallerySubscription}/resourceGroups/${sharedImageGalleryResourceGroup}/providers/Microsoft.Compute/galleries/${sharedImageGalleryName}/images/${sharedImageGalleryDefinitionname}/versions/${sharedImageGalleryVersionName}'

resourceId('Microsoft.Network/networkInterfaces', '${vmPrefix}-${i + currentInstances}${networkAdapterPostfix}')

resourceId('Microsoft.Compute/availabilitySets', '${vmPrefix}-AV')

reference(extensionResourceId('/subscriptions/${subscription().subscriptionId}/resourceGroups/${AVDResourceGroup}', 'Microsoft.Resources/deployments', 'backPlane'), '2019-10-01').outputs.appGroupName.value

resourceId(subscription().subscriptionId, rgAvail.name, 'Microsoft.Compute/availabilitySets', vmadc.availabilitySet)

output appprincipalId1 string = appitglueint.outputs.principalId
output appprincipalId2 object = reference(resourceId(subscription().subscriptionId, rgitglue.name, 'Microsoft.Web/sites', 'app-itglueint-${env}-01'),'2022-03-01').identity.principalId

output vaultUri1 string = kvintexisting.properties.vaultUri
output vaultUri2 string = reference(resourceId(subscription().subscriptionId, rgitglue.name, 'Microsoft.KeyVault/vaults', 'kv-int-${env}-01'),'2022-07-01').vaultUri

output kvu1 string = kv.properties.vaultUri
output kvu2 string = reference(resourceId(subscription().subscriptionId, resourceGroup().name, 'Microsoft.KeyVault/vaults', keyvaultname),'2022-07-01').vaultUri

param a object = resourceGroup(reference(resourceId('Microsoft.Resources/resourceGroups', 'rgname')).name)

subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)

reference(logicApp.id, logicApp.apiVersion, 'Full').identity.principalId
x
