targetScope = 'resourceGroup'

param name string
param tags object

resource actiongrp 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: name
  location: 'global'
  tags: tags
  properties: {
    enabled:  true
    groupShortName: name
    emailReceivers: [
      {
        name: 'Receiver'
        emailAddress: 'name@mail.com'
      }
    ]
  }
}

output actiongrpid string = actiongrp.id
