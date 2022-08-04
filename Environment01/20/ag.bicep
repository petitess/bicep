targetScope = 'resourceGroup'

param name string
param tags object

resource actiongrp 'Microsoft.Insights/actionGroups@2022-04-01' = {
  name: name
  location: 'global'
  tags: tags
  properties: {
    enabled:  true
    groupShortName: name
    emailReceivers: [
      {
        name: 'Karol'
        emailAddress: 'karol.sek@yourmail.se'
      }
    ]
  }
}

output actiongrpid string = actiongrp.id
