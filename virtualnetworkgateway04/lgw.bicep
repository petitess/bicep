targetScope = 'resourceGroup'

param name string
param location string
param gatewayIpAddress string
param addressPrefixes array
param bgpSettings object

var tags = resourceGroup().tags

resource lgw 'Microsoft.Network/localNetworkGateways@2022-07-01' = {
  name: name
  tags: tags
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: addressPrefixes
    }
    gatewayIpAddress: gatewayIpAddress
    bgpSettings: bgpSettings
  }
}

output id string = lgw.id
