targetScope = 'resourceGroup'

param name string
param tags object

resource actiongrp 'Microsoft.Insights/actionGroups@2022-06-01' = {
  name: name
  location: 'global'
  tags: tags
  properties: {
    enabled:  true
    groupShortName: name
    emailReceivers: [
      {
        name: 'Karol'
        emailAddress: 'name@yourmail.se'
      }
    ]
  }
}

output actiongrpid string = actiongrp.id
