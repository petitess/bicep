targetScope = 'managementGroup'

param amplId string

resource plaGUID 'Microsoft.Authorization/privateLinkAssociations@2020-05-01' = {
  name: guid(amplId)
  properties: {
    privateLink: amplId
    publicNetworkAccess: 'Enabled'
  }
}
