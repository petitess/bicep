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

//https://phoenixnap.com/kb/how-to-install-nginx-on-ubuntu-20-04

//https://github.com/Azure/custom-script-extension-linux

//https://askubuntu.com/questions/118025/bypass-the-yes-no-prompt-in-apt-get-upgrade

//https://github.com/Azure/azure-linux-extensions/issues/216

//https://florinloghiade.ro/arm-template-creating-nginx-webfarm-with-custom-script-extension/

//https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux

//https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate_nginx.sh
