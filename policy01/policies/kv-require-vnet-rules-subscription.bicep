targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'KV1'
  properties: {
    displayName: 'KV1: VNet rules must allow flow only from vNets of the same subscription'
    description: 'VNet rules must allow flow only from vNets of the same subscription'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'KeyVault'
    }
    parameters: {
      confValue: {
        allowedValues: [
          'C0'
          'C1'
          'C2'
        ]
        defaultValue: [
          'C0'
          'C1'
          'C2'
        ]
        metadata: {
          description: 'The list of confidentiality tags involved in this policy'
          displayName: 'Resource_ControlTower_Confidentiality tag value'
        }
        type: 'Array'
      }
      effect: {
        allowedValues: [
          'Audit'
          'Deny'
        ]
        defaultValue: 'Audit'
        metadata: {
          description: 'Enforce or Audit the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
      networkProfileValues: {
        allowedValues: [
          'Internet'
        ]
        defaultValue: 'Internet'
        metadata: {
          description: 'The list of resource profile tags involved in this policy'
          displayName: 'Resource profile tag value'
        }
        type: 'string'
      }
      tagConf: {
        defaultValue: 'Resource_ControlTower_Confidentiality'
        metadata: {
          description: 'Confidentiality tag'
          displayName: 'Resource_ControlTower_Confidentiality'
        }
        type: 'String'
      }
      tagResourceProfile: {
        allowedValues: [
          'Resource_ControlTower_Profile'
        ]
        defaultValue: 'Resource_ControlTower_Profile'
        metadata: {
          description: 'Resource profile tag'
          displayName: 'Resource_ControlTower_Profile'
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.KeyVault/vaults'
            field: 'type'
          }
          {
            equals: '''[parameters('networkProfileValues')]'''
            field: '''[concat('tags[', parameters('tagResourceProfile'), ']')]'''
          }
          {
            field: '''[concat('tags[', parameters('tagConf'), ']')]'''
            in:  '''[parameters('confValue')]'''
          }
          {
            count: {
              field: 'Microsoft.KeyVault/vaults/networkAcls.virtualNetworkRules[*]'
            }
            greater: 0
          }
          {
            field: 'Microsoft.KeyVault/vaults/networkAcls.virtualNetworkRules[*].id'
            notcontains: '''[subscription().id]'''
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
