param vdaCount int

var tags = resourceGroup().tags

resource vda 'Microsoft.Compute/virtualMachines@2023-07-01' existing = [for (vda, i) in range(0, vdaCount): {
  name: i + 1 < 10 ? 'vmvdaprod0${i + 1}' : 'vmvdaprod${i + 1}'
}]

resource vdatags 'Microsoft.Resources/tags@2023-07-01' = [for (tag, i) in range(0, vdaCount): {
  name: 'default'
  scope: vda[i]
  properties: {
    tags: i + 1 == 1 || i + 1 == 2 ? union(tags, {
        Application: 'Citrix'
        UpdateManagement: 'NotSupported'
        Restart: contains(vda[i].name, '1') ? 'GroupA' : 'GroupB'
      }) : union(tags, {
        Application: 'Citrix'
        UpdateManagement: 'NotSupported'
        AutoShutdown: i + 1 <= 9 ? 'GroupA' : i + 1 > 9 && i + 1 > 16 ? 'GroupC' : 'GroupB'
      })
  }
}]
