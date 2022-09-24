resourceId(vnetrg, 'Microsoft.Network/virtualNetworks/subnets', vnetname, interface.subnet)

resourceId('Microsoft.Compute/disks', '${name}-${dataDisk.name}')
