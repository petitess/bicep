targetScope = 'subscription'

resource definition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'VM2'
  properties: {
    displayName: 'VM2: Public IP card are not allowed'
    description: 'Public IP card are not allowed'
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'VirtualMAchine'
    }
    parameters: {
      effect: {
        allowedValues: [
          'Audit'
          'Deny'
        ]
        defaultValue: 'Audit'
        metadata: {
          description: 'Activate or deactivate the execution of the policy'
          displayName: 'Effect'
        }
        type: 'String'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.Network/networkInterfaces'
            field: 'type'
          }
          {
            count: {
              field: 'Microsoft.Network/networkInterfaces/ipconfigurations[*]'
              where: {
                allOf: [
                  {
                    exists: true
                    field: 'Microsoft.Network/networkInterfaces/ipconfigurations[*].publicIpAddress'
                  }
                  {
                    field: 'Microsoft.Network/networkInterfaces/ipconfigurations[*].publicIpAddress.id'
                    notEquals: ''
                  }
                ]
              }
            }
            greater: 0
          }
        ]
      }
      then: {
        effect: '''[parameters('effect')]'''
      }
    }
  }
}
