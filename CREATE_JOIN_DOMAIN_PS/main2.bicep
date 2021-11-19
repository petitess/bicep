targetScope = 'subscription'

param Number string = '01'

param RG1Name string = 'zrg-vm-test-ad-${Number}'
param RG2Name string = 'zrg-vm-test-web-${Number}'
param RG3Name string = 'zrg-vnet-test-${Number}'

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
    existingVnetName: Vnet.name
    subnetId: Vnet.outputs.SubnetWEB
    prefix: 'WEB${Number}'
    //availabilitySetName: 'as-citrix-001'
    //availabilitySetPlatformFaultDomainCount: 2
    //availabilitySetPlatformUpdateDomainCount: 5
    //CCVMPrefix: 'vm-ctx-cc'
    //domainFQDN: 'b3'
    //domainJoinUserName: 'sek'
    //domainJoinUserPassword: '12345678.abc'
    //location: resourceGroup().location
    //OS: 'Server2019'
    //ouPath: 'OU=Computers,DC=b3,DC=test'
    //SubnetName: Vnet.outputs.SubnetMGT
    //virtualMachineCount: 4
    //VMPassword: 'InsertPassword'
    //VMSize: 'Standard_D2s_v3'
    //VMUserName: 'azureadmin'
    //vNetName: Vnet.name
    //vNetResourceGroup: RG3.id
    //subnetRef: Vnet.outputs.SubnetMGT
    existingSubnetName: Vnet.outputs.SubnetWEB

  }
}


module Vnet 'Vnet01.bicep' = {
  name: 'Vnetdeploy'
  scope: RG3
  params:{
    VnetName: 'vnet-dev-${Number}'
  }
}
