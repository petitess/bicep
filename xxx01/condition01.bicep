resource vda 'Microsoft.Compute/virtualMachines@2023-03-01' existing = [for (vda, i) in range(0, vdaCount): {
  name: (i + 1) < 10 ? 'vmvdaprod0${i + 1}' : 'vmvdaprod${i + 1}'
}]
