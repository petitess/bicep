targetScope = 'subscription'
extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'
param groupName string
@retryOn(['NotFound'], 5)
resource pimGroupsE 'Microsoft.Graph/groups@v1.0' existing = {
  uniqueName: groupName
}

output objectId string = pimGroupsE.id
