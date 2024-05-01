param name string
param location string
param tags object = resourceGroup().tags
param snetPepId string
param snetPublicName string
param snetPrivateName string
param vnetId string
param dnsRgName string
param privateEndpoints array
param adfObjectId string

func insertPrefix(x string, y string) string =>
  '${substring(x, 0, length(x) - 2)}${y}-${substring(x, length(x) - 2, 2)}'

resource dbw 'Microsoft.Databricks/workspaces@2023-09-15-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'premium'
  }
  properties: {
    managedResourceGroupId: subscriptionResourceId(
      'Microsoft.Resources/resourceGroups',
      insertPrefix(resourceGroup().name, 'managed')
    )
    requiredNsgRules: 'NoAzureDatabricksRules'
    publicNetworkAccess: 'Disabled'
    parameters: {
      customPrivateSubnetName: {
        value: snetPrivateName
      }
      customPublicSubnetName: {
        value: snetPublicName
      }
      customVirtualNetworkId: {
        value: vnetId
      }
      enableNoPublicIp: {
        value: true
      }
      prepareEncryption: {
        value: false
      }
      requireInfrastructureEncryption: {
        value: false
      }
      storageAccountName: {
        value: 'st${replace(name, '-', '')}'
      }
      storageAccountSkuName: {
        value: 'Standard_GRS'
      }
    }
  }
}

@batchSize(1)
resource pep 'Microsoft.Network/privateEndpoints@2023-09-01' = [
  for pep in privateEndpoints: {
    name: 'pep-${substring(name, 0, length(name) - 2)}${replace(pep, '_', '-')}${substring(name, length(name) - 2, 2)}'
    location: location
    tags: tags
    properties: {
      customNetworkInterfaceName: 'nic-pep-${substring(name, 0, length(name) - 2)}${replace(pep, '_', '-')}${substring(name, length(name) - 2, 2)}'
      privateLinkServiceConnections: [
        {
          name: '${dbw.name}-${replace(pep, '_', '-')}'
          properties: {
            privateLinkServiceId: dbw.id
            groupIds: [
              pep
            ]
          }
        }
      ]
      subnet: {
        id: snetPepId
      }
    }
  }
]

resource dns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = [
  for (dns, i) in privateEndpoints: {
    name: 'default'
    parent: pep[i]
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-${dns}-core-windows-net'
          properties: {
            privateDnsZoneId: resourceId(
              dnsRgName,
              'Microsoft.Network/privateDnsZones',
              'privatelink.azuredatabricks.net'
            )
          }
        }
      ]
    }
  }
]

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, adfObjectId, 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  scope: dbw
  properties: {
    principalId: adfObjectId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'b24988ac-6180-42a0-ab88-20f7382dd24c'
    )
    principalType: 'ServicePrincipal'
  }
}

output id string = dbw.id
output url string = dbw.properties.workspaceUrl
