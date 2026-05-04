param name string
param location string
param keyVaultId string
param keyUrl string
param rbac ('Key Vault Crypto Service Encryption')[] = ['Key Vault Crypto Service Encryption']

var rolesList = {
  'Key Vault Crypto Service Encryption': 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
}
resource des 'Microsoft.Compute/diskEncryptionSets@2025-01-02' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    activeKey: {
      sourceVault: {
        id: keyVaultId
      }
      keyUrl: keyUrl
    }
    encryptionType: 'EncryptionAtRestWithCustomerKey'
  }
}

resource rbacR 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (r, i) in rbac: if (rbac != []) {
    name: guid(resourceGroup().id, des.id, string(i))
    properties: {
      principalId: des.identity.principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleAssignments', rolesList[r])
      principalType: 'ServicePrincipal'
    }
  }
]

output desId string = des.id
