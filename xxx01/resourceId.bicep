////////////////////////////////
////////////RESOURCE GROUP//////
///////////////////////////////
resourceId(vnetrg, 'Microsoft.Network/virtualNetworks/subnets', vnetname, interface.subnet)
subscriptionResourceId('Microsoft.insights/eventTypes', 'management')
resourceId('Microsoft.Compute/disks', '${name}-${dataDisk.name}')

output a string = 'subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/azureblob'
output b string = extensionResourceId(subscription().id, 'Microsoft.Web/locations/managedApis', location, 'azureblob')

resourceId(sharedImageGalleryResourceGroup, 'Microsoft.Compute/galleries/images/versions', sharedImageGalleryName, sharedImageGalleryDefinitionname, sharedImageGalleryVersionName)
'/subscriptions/${sharedImageGallerySubscription}/resourceGroups/${sharedImageGalleryResourceGroup}/providers/Microsoft.Compute/galleries/${sharedImageGalleryName}/images/${sharedImageGalleryDefinitionname}/versions/${sharedImageGalleryVersionName}'

resourceId('Microsoft.Network/networkInterfaces', '${vmPrefix}-${i + currentInstances}${networkAdapterPostfix}')

resourceId('Microsoft.Compute/availabilitySets', '${vmPrefix}-AV')

output appprincipalId1 string = appitglueint.outputs.principalId
output appprincipalId2 object = reference(resourceId(subscription().subscriptionId, rgitglue.name, 'Microsoft.Web/sites', 'app-itglueint-${env}-01'),'2022-03-01').identity.principalId

output vaultUri1 string = kvintexisting.properties.vaultUri
output vaultUri2 string = reference(resourceId(subscription().subscriptionId, rgitglue.name, 'Microsoft.KeyVault/vaults', 'kv-int-${env}-01'),'2022-07-01').vaultUri

output kvu1 string = kv.properties.vaultUri
output kvu2 string = reference(resourceId(subscription().subscriptionId, resourceGroup().name, 'Microsoft.KeyVault/vaults', keyvaultname),'2022-07-01').vaultUri

param a object = resourceGroup(reference(resourceId('Microsoft.Resources/resourceGroups', 'rgname')).name)

subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)

output poolid1 string = '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${name}/backendAddressPools/${backendAddressPools[0].name}'
output poolid2 string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, backendAddressPools[0].name)

output ipconfig1 string = '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${name}/frontendIPConfigurations/${name}-privip'
output ipconfig2 string = resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name, '${name}-privip')

output probe1 string = '${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/loadBalancers/${name}/probes/${probes[0].name}'
output probe2 string = resourceId('Microsoft.Network/loadBalancers/probes', name, probes[0].name)
//////////////////////////
///////SUBSCRIPTION///////
//////////////////////////
resourceId(subscription().subscriptionId, rginfra1.name, 'Microsoft.Network/virtualNetworks/subnets', vnet01.outputs.name , param.lb.subnetname)
resourceId(subscription().subscriptionId, rgAvail.name, 'Microsoft.Compute/availabilitySets', vmadc.availabilitySet)
resourceId(subscription().subscriptionId, rginfra.name, 'Microsoft.Storage/storageAccounts', param.st[0].name)
subscriptionResourceId('Microsoft.Resources/resourceGroups', rginfra.name)

//REFERENCE
replace(reference(snetId, '2022-09-01').addressPrefix, '.0/24', '.5')
reference(resourceId('Microsoft.Network/networkInterfaces', 'nic-${name}'), '2022-09-01').ipConfigurations[0].properties.privateIPAddress 
reference(extensionResourceId('/subscriptions/${subscription().subscriptionId}/resourceGroups/${AVDResourceGroup}', 'Microsoft.Resources/deployments', 'backPlane'), '2019-10-01').outputs.appGroupName.value
reference(resourceId('Microsoft.Network/virtualNetworkGateways', vgwname), '2022-07-01').ipConfigurations[0].id
reference(logicApp.id, logicApp.apiVersion, 'Full').identity.principalId
reference(cosmosDbConnector.id, cosmosDbConnector.apiVersion, 'full').properties.connectionRuntimeUrl
x
