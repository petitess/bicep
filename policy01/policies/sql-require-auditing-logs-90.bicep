targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'SQL4'
  properties: {
    displayName: 'SQL4: Auditing for Azure SQL Database must be activated and stored at least 90days'
    description: 'Auditing for Azure SQL Database must be activated and stored at least 90days'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Sql'
    }
    parameters: {
      effect: {
        allowedValues: [
          'AuditIfNotExists'
          'disabled'
        ]
        defaultValue: 'AuditIfNotExists'
        metadata: {
          description: 'Activate or deactivate the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
      retentionDays: {
        defaultValue: 89
        metadata: {
          displayName: 'Desired Auditing retention days'
        }
        type: 'Integer'
      }
      state: {
        allowedValues: [
          'enabled'
          'disabled'
        ]
        defaultValue: 'enabled'
        metadata: {
          displayName: 'Desired Auditing setting state'
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.Sql/servers'
            field: 'type'
          }
        ]
      }
      then: {
        details: {
          existenceCondition: {
            allof: [
              {
                equals: '''[parameters('state')]'''
                field: 'Microsoft.Sql/servers/AuditingSettings/default.state'
              }
              {
                field: 'Microsoft.Sql/servers/AuditingSettings/default.retentionDays'
                greater: '''[parameters('retentionDays')]'''
              }
            ]
          }
          name: 'default'
          type: 'Microsoft.Sql/servers/AuditingSettings'
        }
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
