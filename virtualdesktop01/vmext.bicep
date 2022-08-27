targetScope = 'resourceGroup'

param name string
param location string
var tags = resourceGroup().tags
param adminUsername string
param adminPassword string
param domainFQDN string

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' existing = {
  name: name
}

resource joindomain 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' =  {
  name: 'joindomain'
  location: location
  tags: tags
  parent: vm
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: domainFQDN
      User: '${domainFQDN}\\${adminUsername}'
      Restart: 'true'
      Options: 3
    }
    protectedSettings: {
      Password: adminPassword
    }
  }
}

