resource vda 'Microsoft.Compute/virtualMachines@2023-03-01' existing = [for (vda, i) in range(0, vdaCount): {
  name: i + 1 < 10 ? 'vmvdaprod0${i + 1}' : 'vmvdaprod${i + 1}'
}]

resource vdatags 'Microsoft.Resources/tags@2022-09-01' = [for (tag, i) in range(0, vdaCount): {
  name: 'default'
  scope: vda[i]
  properties: {
    tags: union(tags, {
        Application: 'Citrizzz'
        UpdateManagement: 'NotSupported'
        Restart: contains(vda[i].name, '1') ? 'GroupA' : 'GroupB'
      })
  }
}]
