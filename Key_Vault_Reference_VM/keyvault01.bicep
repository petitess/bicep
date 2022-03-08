//param vaultName string = 'keyVault-${uniqueString(resourceGroup().id)}' // must be globally unique
param vaultName string = 'keyVault-20220308' // must be globally unique
param location string = resourceGroup().location
param sku string = 'Standard'
param tenant string = '7d5e28a9-aa48-43c6-a39a-3fc5167644' // replace with your tenantId
param accessPolicies array = [
  {
    tenantId: tenant
    objectId: '804fadca-ed24-43b4-8048-173a6fb152' // replace with your objectId
    permissions: {
      keys: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        
      ]
      secrets: [
        'Get'
        'List'
        'Set'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        
      ]
      certificates: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        'ManageContacts'
        'ManageIssuers'
        'GetIssuers'
        'ListIssuers'
        'SetIssuers'
        'DeleteIssuers'
        
      ]
    }
  }

  {
    tenantId: tenant
    objectId: '7ac4f416-9125-4e27-808d-215cc8c16b' // replace with your objectId
    permissions: {
      keys: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        
      ]
      secrets: [
        'Get'
        'List'
        'Set'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        
      ]
      certificates: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        'ManageContacts'
        'ManageIssuers'
        'GetIssuers'
        'ListIssuers'
        'SetIssuers'
        'DeleteIssuers'
        
      ]
    }
  }

]

param enabledForDeployment bool = true
param enabledForTemplateDeployment bool = true
param enabledForDiskEncryption bool = true
param enableRbacAuthorization bool = false
param softDeleteRetentionInDays int = 90

param keyName string = 'prodKey'

//@secure()
//param secretName string = newGuid()

//Generate a random key
@secure()
param secretValue string = newGuid()

param networkAcls object = {
  ipRules: []
  virtualNetworkRules: []
}

resource keyvault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: vaultName
  location: location
  properties: {
    tenantId: tenant
    sku: {
      family: 'A'
      name: sku
    }
    accessPolicies: accessPolicies
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: enableRbacAuthorization
    networkAcls: networkAcls
  }
}
resource key 'Microsoft.KeyVault/vaults/keys@2021-10-01' = {
  name: '${keyvault.name}/${keyName}'
  properties: {
    kty: 'RSA' // key type
    keyOps: [
      // key operations
      'encrypt'
      'decrypt'
    ]
  }
}

// create secret
resource secret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${keyvault.name}/vmad01pass'
  properties: {
    value: secretValue
  }
}

resource secret02 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${keyvault.name}/srvpass'
  properties: {
    value: secretValue
  }
}

output secret01  string = secret.id
