resource vmWeb0xName_CustomScript 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if(LinuxOS) {
  name: 'CustomScript'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      commandToExecute: 'apt install nginx -y'
    }
  }
}
