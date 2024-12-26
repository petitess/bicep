targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'ST2'
  properties: {
    displayName: 'ST2: IP rules must be set to allow traffic only from specific IPs'
    description: 'IP rules must be set to allow traffic only from specific IPs'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Storage'
    }
    parameters: {
      WAFImpervaIP: {
        defaultValue: [
          '1.83.128.0/21'
          '1.143.32.0/19'
          '1.126.72.0/21'
          '1.28.248.0/22'

        ]
        metadata: {
          description: 'The list of WAF Imperva IP addresses ranges'
          displayName: 'WAF Imperva IPs'
        }
        type: 'array'
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
          'authenticatedPublicBlob'
        ]
        defaultValue: [
          'authenticatedPublicBlob'
        ]
        metadata: {
          description: 'The list of resource profile tags involved in this policy'
          displayName: 'Resource profile tag value'
        }
        type: 'array'
      }
      tagResourceProfile: {
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
            allOf: [
              {
                equals: 'Microsoft.Storage/storageAccounts'
                field: 'type'
              }
              {
                exists: true
                field: '''[concat('tags[', parameters('tagResourceProfile'), ']')]'''
              }
              {
                field: '''[concat('tags[', parameters('tagResourceProfile'), ']')]'''
                in: '''[parameters('networkProfileValues')]'''
              }
            ]
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Storage/storageAccounts/networkAcls.ipRules[*].value'
                notIn: '''[parameters('WAFImpervaIP')]'''
              }
              {
                equals: 'Allow'
                field: 'Microsoft.Storage/storageAccounts/networkAcls.defaultAction'
              }
            ]
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
