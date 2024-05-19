var subnet = toObject(reference(
  resourceId(subscription().subscriptionId, rg.name, 'Microsoft.Network/virtualNetworks', 'vnet-${prefix}-01'),
  '2023-09-01'
).subnets, subnet => subnet.name)
output sub string = subnet['snet-pep'].id
