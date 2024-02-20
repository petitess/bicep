var docker1 = 'sudo apt-get update'
var docker2 = 'sudo apt-get install ca-certificates curl'
var docker3 = 'sudo install -m 0755 -d /etc/apt/keyrings'
var docker4 = 'sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc'
var docker5 = 'sudo chmod a+r /etc/apt/keyrings/docker.asc'
var docker6 = 'sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null'
var docker7 = 'sudo apt-get update'
var docker8 = 'sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y'
var docker = '${docker1};${docker2};${docker3};${docker4};${docker5};${docker6};${docker7};${docker8}'

resource nginx 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = if(LinuxOS) {
  name: 'CustomScript'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      commandToExecute: docker
    }
  }
}
