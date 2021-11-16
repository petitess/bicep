targetScope = 'subscription'

param Number string = '01'

param RG1Name string = 'xrg-vm-cgm-ad-${Number}'
param RG2Name string = 'xrg-vm-cgm-web-${Number}'
param RG3Name string = 'xrg-vm-cgm-sql-${Number}'
param RG4Name string = 'xrg-vnet-cgm-${Number}'
param RG5Name string = 'xrg-vm-cgm-web-02'

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

resource RG5 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RG5Name
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

module Web 'VM_WEB.bicep' = {
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

module Web02  'VM_WEB02.bicep' = {
  name: 'WEB02deploy'
  scope: RG5
  params: {
    prefix: 'WEB02'
    SubnetPath: Vnet.outputs.SubnetWEB
  }
}

module Vnet 'Vnet01.bicep' = {
  name: 'Vnetdeploy'
  scope: RG4
  params:{
    VnetName: 'vnet-dev-${Number}'
  }
}
