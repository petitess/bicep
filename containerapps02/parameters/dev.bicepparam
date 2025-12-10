using '../main.bicep'

param env = 'dev'
param tags = {
  product: 'infra'
}

param storageAccounts = [
  {
    name: 'stollamadev01'
    skuName: 'Standard_LRS'
    isSftpEnabled: false
    publicAccess: 'Enabled'
    allowedIPs: []
    privateEndpoints: {}
    shares: [
      'ollamafileshare'
      'openwebuifileshare'
    ]
    containers: []
  }
]
