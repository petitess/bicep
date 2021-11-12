targetScope = 'subscription'

param Number string = '01'

param RG1Name string = 'rg-vm-ad-${Number}'
param RG2Name string = 'rg-vm-web-${Number}'
param RG3Name string = 'rg-vm-sql-${Number}'
param RG4Name string = 'rg-vnet-${Number}'

resource RG1 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RG1Name
  location: 'westeurope' 
}

resource RG2 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RG2Name
  location: 'westeurope'
}


resource RG3 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RG3Name
  location: 'westeurope'
}

resource RG4 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RG4Name
  location: 'westeurope'
}


module AD 'VM_AD01.bicep' = {
  name: 'ADdeploy'
  scope: RG1
  params: {
    prefix: 'AD${Number}'
    SubnetPath: Vnet.outputs.SubnetAD
  }
}

module Web 'VM_WinWeb.bicep' = {
  name: 'WEBdeploy'
  scope: RG2
  params: {
    prefix:'WEB${Number}'
    SubnetPath: Vnet.outputs.SubnetWEB
  }
}

module WinSQL 'VM_WinSQL01.bicep' = {
  name: 'WinSQLdeploy'
  scope: RG3
  params: {
    prefix: 'SQL${Number}'
    SubnetPath: Vnet.outputs.SubnetDB
  }
}

module Vnet 'Vnet01.bicep' = {
  name: 'Vnetdeploy'
  scope: RG4
  params:{
    VnetName: 'vnet-dev-${Number}'
  }
}
