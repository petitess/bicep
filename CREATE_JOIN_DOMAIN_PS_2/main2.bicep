targetScope = 'subscription'

param Number string = '01'

param RG1Name string = 'yrg-vm-test-ad-${Number}'
param RG2Name string = 'yrg-vm-test-web-${Number}'
param RG3Name string = 'yrg-vnet-test-${Number}'

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
    prefix: 'WEB${Number}'
    SubnetPath: Vnet.outputs.SubnetWEB
    

  }
}


module Vnet 'Vnet01.bicep' = {
  name: 'Vnetdeploy'
  scope: RG3
  params:{
    VnetName: 'vnet-dev-${Number}'
  }
}
