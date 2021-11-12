param natGatewayName string = 'NATGateway'
param bastion_name string = 'MIMBastion'
param vnet_name string = 'mim-vnet'
param public_IPAddress_name string = 'mim-vnet-ip'
//param location string = 'eastus'
param location string = resourceGroup().location
param webSubnet_name string = 'WebSubnet'
param SQLSubnet_name string = 'SQLSubnet'
param appSubnet_name string = 'AppSubnet'
param dcSubnet_name string = 'DCSubnet'

resource bastionHostIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'bastionIPName'
  location:  location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    ipAddress: '52.149.209.76'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource natGatewayIPname 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'natGatewayPublicIPName'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    ipAddress: '20.106.167.52'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource natGatewayName_resource 'Microsoft.Network/natGateways@2020-11-01' = {
  name: natGatewayName
  location:  location
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 10
    publicIpAddresses: [
      {
        id: natGatewayIPname.id
      }
    ]
  }
}

resource public_IPAddress_name_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: public_IPAddress_name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    ipAddress: '52.181.127.197'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource vnet_name_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnet_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.0.0/27'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: webSubnet_name
        properties: {
          addressPrefix: '10.0.1.0/27'
          natGateway: {
            id: natGatewayName_resource.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: SQLSubnet_name
        properties: {
          addressPrefix: '10.0.2.0/27'
          natGateway: {
            id: natGatewayName_resource.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: appSubnet_name
        properties: {
          addressPrefix: '10.0.3.0/27'
          natGateway: {
            id: natGatewayName_resource.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: dcSubnet_name
        properties: {
          addressPrefix: '10.0.4.0/27'
          natGateway: {
            id: natGatewayName_resource.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource vnet_name_dcSubnet 'Microsoft.Network/VirtualNetworks/subnets@2019-11-01' = {
  parent: vnet_name_resource
  name: 'dcSubnet'
  properties: {
    addressPrefix: '10.0.4.0/27'
    natGateway: {
      id: natGatewayName_resource.id
    }
    serviceEndpoints: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource vnet_name_AzureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: vnet_name_resource
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: '10.0.0.0/27'
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource bastion_name_resource 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: bastion_name
  location: location
  properties: {
    dnsName: 'bst-f1e99eeb-bd3a-452e-95f2-c4b329153292.bastion.azure.com'
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: public_IPAddress_name_resource.id
          }
          subnet: {
            id: vnet_name_AzureBastionSubnet.id
          }
        }
      }
    ]
  }
}

module dcModule 'Domain-Controller.bicep' = {
  name: 'dcDeploy'
  params:{
    location: location
    subNetID: vnet_name_dcSubnet.id
  }
  dependsOn: [
    vnet_name_dcSubnet
  ]
}


module acModule 'AD.bicep' = {
  name: 'adDeploy'
  params:{
    location: location
    subNetID: vnet_name_dcSubnet.id
  }
  dependsOn: [
    vnet_name_dcSubnet
  ]
}
