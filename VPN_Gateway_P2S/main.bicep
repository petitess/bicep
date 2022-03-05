targetScope = 'subscription'

param Number string = '01'
param Number2 string = '02'
param location string = 'swedencentral'

param RG1Name string = 'rg-vm-ad-${Number}'
param RG2Name string = 'rg-vm-web-${Number}'
param RG3Name string = 'rg-vnet-${Number2}'
param RG4Name string = 'rg-vnet-${Number}'

resource RG1 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RG1Name
  location: location
}

resource RG2 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RG2Name
  location: location
}


resource RG3 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RG3Name
  location: location
}

resource RG4 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RG4Name
  location: location
}

module Vnet 'Vnet01.bicep' = {
  name: 'Vnetdeploy01'
  scope: RG4
  params:{
    VnetName: 'vnet-dev-${Number}'
    locationRG: location
  }
  
}

module VNGW 'VNgateway01.bicep' = {
  scope: RG4
  name: 'VNGW01'
  params: {
    subnetid: Vnet.outputs.GatewaySubnet
    location: location
  }
}

module Vnet2 'Vnet02.bicep' = {
  name: 'Vnetdeploy02'
  scope: RG3
  params:{
    VnetName: 'vnet-dev-${Number2}'
    locationRG: location
  }
  
}

module AD 'VM_AD01.bicep' = {
  name: 'ADdeploy'
  scope: RG1
  params: {
    prefix: 'AD${Number}'
    SubnetPath: Vnet.outputs.SubnetAD
    location: location
  }
}

module Web 'VM_WinWeb.bicep' = {
  name: 'WEBdeploy'
  scope: RG2
  params: {
    prefix:'WEB${Number}'
    SubnetPath: Vnet.outputs.SubnetAPP
    location: location
  }
}



