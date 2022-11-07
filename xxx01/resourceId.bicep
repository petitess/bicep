resourceId(vnetrg, 'Microsoft.Network/virtualNetworks/subnets', vnetname, interface.subnet)

resourceId('Microsoft.Compute/disks', '${name}-${dataDisk.name}')

resourceId(sharedImageGalleryResourceGroup, 'Microsoft.Compute/galleries/images/versions', sharedImageGalleryName, sharedImageGalleryDefinitionname, sharedImageGalleryVersionName)
'/subscriptions/${sharedImageGallerySubscription}/resourceGroups/${sharedImageGalleryResourceGroup}/providers/Microsoft.Compute/galleries/${sharedImageGalleryName}/images/${sharedImageGalleryDefinitionname}/versions/${sharedImageGalleryVersionName}'

resourceId('Microsoft.Network/networkInterfaces', '${vmPrefix}-${i + currentInstances}${networkAdapterPostfix}')

resourceId('Microsoft.Compute/availabilitySets', '${vmPrefix}-AV')

reference(extensionResourceId('/subscriptions/${subscription().subscriptionId}/resourceGroups/${AVDResourceGroup}', 'Microsoft.Resources/deployments', 'backPlane'), '2019-10-01').outputs.appGroupName.value

resourceId(subscription().subscriptionId, rgAvail.name, 'Microsoft.Compute/availabilitySets', vmadc.availabilitySet)

x
