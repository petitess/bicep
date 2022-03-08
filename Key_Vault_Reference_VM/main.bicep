targetScope = 'subscription'

param Number string = '01'
param Number2 string = '02'
param location string = 'swedencentral'

param RG1Name string = 'rg-vm-ad-${Number}'
param RG2Name string = 'rg-vm-web-${Number}'
param RG3Name string = 'rg-vnet-${Number2}'
param RG4Name string = 'rg-vnet-${Number}'
param RG5Name string = 'rg-keyvault-${Number}'

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

resource RG5 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RG5Name
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

module keyvault01 'keyvault01.bicep' = {
  scope: RG5  
  name: 'keyvaultdeploy'
  params: {
    location: location

  } 
}

resource keyvault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: 'keyVault-20220308' 
  scope: RG5
}

module AD 'VM_AD01.bicep' = {
  name: 'ADdeploy'
  scope: RG1
  dependsOn: [
    keyvault01
  ]
  params: {
    prefix: 'VMAD${Number}'
    SubnetPath: Vnet.outputs.SubnetAD
    location: location
    //Reference Key Vault
    AdminPassword: keyvault.getSecret('vmad01pass')
  }
}



