targetScope = 'subscription'

param config object
param virtualnetwork object
param virtualMachines array
param virtualMachinesAvail array
param bastion object
param vgateway object
param st array
param updateSchedules array

var location = config.location.name
var location2 = config.location.alt.name
var envloc = toLower('${config.environment.affix}-${config.location.affix}')
var envloc2 = toLower('${config.environment.affix}-${config.location.alt.affix}')
var subid = take(subscription().subscriptionId, 5)
var tags = {
  Company: config.company.name
  Environment: config.environment.name
}
var categories = [
  'Administrative'
  'Security'
  'ServiceHealth'
  'Alert'
  'Recommendation'
  'Policy'
  'Autoscale'
  'ResourceHealth'
]

resource RG1 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-vnet-${envloc}-01'
  location: location
  tags: union(tags, {
    Application: 'Infrastructure'
  })
}

module vnet 'vnet.bicep' = {
  scope: RG1 
  name: 'module-${envloc}-vnet01'
  params: {
    name: 'vnet-${envloc}-01'
    location: location
    addressPrefixes: virtualnetwork.addressPrefixes
    dnsServers: virtualnetwork.dnsServers
    subnets: virtualnetwork.subnets
  }
}

resource RG2 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-govern-${envloc}-01'
  location: location
  tags: union(tags, {
    Application : 'Governance'
})
}

module keyvault 'kv.bicep' = {
  scope: RG2
  name: 'module-${envloc}-kv01'
  params: {
    location: location
    kvname: 'kv-${subid}-${envloc}-01'
  }
}

module id 'id.bicep' = {
  scope: RG2
  name: 'module-${envloc}-id01'
  params: {
    location: location
    name: 'id-${subid}-${envloc}-01'
  }
}

resource role01 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid('role-${subid}-${envloc}-01')
  dependsOn: [
    id
  ]
  properties: {
    principalId: id.outputs.id
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    description: 'Contributor'
    principalType: 'ServicePrincipal'
  }
}

resource role02 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid('role-${subid}-${envloc}-02')
  dependsOn: [
    id
  ]
  properties: {
    principalId: id.outputs.id
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
    description: 'Key Vault Admin'
    principalType: 'ServicePrincipal'
  }
}

module script 'script.bicep' = {
  scope: RG2
  dependsOn: [
    id
  ]
  name: 'module-${envloc}-script01'
  params: {
    location: location2
    name: 'script-${subid}-${envloc2}-01'
    idName: id.outputs.idname
    kvName: keyvault.outputs.kvname
    virtualMachines: virtualMachines
    virtualMachinesAvail: virtualMachinesAvail
  }
}

resource kvexisting 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: 'kv-${subid}-${envloc}-01'
  scope: RG2
}

resource rgvm 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vm in virtualMachines: {
  name: 'rg-${vm.name}'
  location: location
  tags: union(tags, {
    Application: vm.tags.Application
  })
}]

module vm 'vm.bicep' = [for (vm, i) in virtualMachines: {
  name: 'module-${vm.name}'
  scope: rgvm[i]
  dependsOn: [
    script
    vmlog
  ]
  params: {
    adminPassword: kvexisting.getSecret(vm.name)
    adminUsername: kvexisting.getSecret(keyvault.outputs.username)
    osdiskSizeGB: vm.osdiskSizeGB
    osdiskname: '${vm.name}-OSdisk-${subid}'
    imageReference: vm.imageReference
    location: location
    name: vm.name
    networkinterfaces: vm.networkinterfaces
    tags: union(rgvm[i].tags, vm.tags)
    vmSize: vm.vmSize
    vnetid: vnet.outputs.vnetid
    datadisks: vm.datadisks
    osWindows: vm.osWindows
    workspaceId: vmlog.outputs.workspaceId
    workspaceApi: vmlog.outputs.workspaceApi
    backupEnabled: vm.backupEnabled
    policyId: rsv.outputs.rsvpolicy01id
    rsvName: rsv.outputs.rsvname
    rsvRgName: rgrsv.name
  }
}]

module ag 'ag.bicep' = {
  scope: RG2
  name: 'module-${envloc}-ag01'
  params: {
    name: replace('AG${envloc}01', '-', '')
    tags: {
    }
  }
}

module alert 'vmalert.bicep' = {
  scope: RG2
  name: 'module-${envloc}-alert01'
  dependsOn: [
    vm
  ]
  params: {
    tags: tags
    virtualMachines: virtualMachines
    actionGroupId: ag.outputs.actiongrpid
  }
}

resource rglog 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-log-${envloc2}-01'
  location: location2
  tags: union(tags, {
    Application: 'Infrastructure'
  })
}

module vmlog 'vmlog.bicep' = {
  scope: rglog
  name: 'module-${envloc2}-log01'
  params: {
    location: location2
    name: 'log-vm-${envloc2}-01'
    aaid: aa.outputs.aaId
  }
}

module logalert 'vmlogalert.bicep' = {
  name: 'module-${envloc}-logalert01'
  scope: rglog
  dependsOn: [
    vm
  ]
  params: {
    actionGroup: ag.outputs.actiongrpid
    location: location
    virtualMachines: virtualMachines
    workspaceId: vmlog.outputs.workspaceId
  }
}

resource rgrsv 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-rsv-${envloc}-01'
  location: location
  tags: union(tags, {
    Application: 'Infrastructure'
  })
}

module rsv 'rsv.bicep' = {
  scope: rgrsv
  name: 'module-${envloc}-rsv01'
  params: {
    location: location
    name: 'rsv-${envloc}-01'
  }
}

resource rgbastion 'Microsoft.Resources/resourceGroups@2021-04-01' = if(bastion.deploy) {
  name: 'rg-bastion-${envloc}-01'
  location: location
  tags: union(tags, {
    Application: 'Infrastructure'
  })
}

module bastion01 'bastion.bicep' = if(bastion.deploy) {
  scope: rgbastion
  name: 'module-${envloc}-bastion01'
  params: {
    name: 'bas-${envloc}-01'
    location: location
    subnet: '${vnet.outputs.vnetid}/subnets/AzureBastionSubnet'
  }
}

resource logdiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'actlog-diag-${envloc}-01'
  properties: {
    workspaceId: vmlog.outputs.workspaceId
    logs: [for category in categories:{
      category: category
      enabled: true
        }]
      }
}

resource rgnw 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-nw-${envloc}-01'
  location: location
  tags: union(tags, {
    Application: 'Infrastructure'
  })
}

module nw 'nw.bicep' = {
  scope: rgnw
  name: 'module-${envloc}-netw01'
  dependsOn: [
    vm
  ]
  params: {
    location: location
    name: 'netw-${envloc}-01'
    virtualMachines: virtualMachines
    workspaceResourceId: vmlog.outputs.workspaceId
    actionGroupId: ag.outputs.actiongrpid 
  }
}

module vgw 'vgw.bicep' = if(vgateway.enable) {
  scope: RG1
  name: 'module-${envloc}-vgw01'
  params: {
    location: location
    lgwname: 'lgw-${envloc}-01'
    vgwname: 'vgw-${envloc}-01'
    vgateway: vgateway
    subnetid: '${subscription().id}/resourceGroups/${RG1.name}/providers/Microsoft.Network/virtualNetworks/${vnet.outputs.vnetname}/subnets/GatewaySubnet'
  }
}

resource rgst 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-st-${envloc}-01'
  tags: tags
  location: location
}

module st01 'st.bicep' = [for storage in st: {
  scope: rgst
  name: 'module-${storage.name}'
  params: {
    kind: storage.kind
    location: location
    name: storage.name
    sku: storage.sku
    fileShares: storage.fileShares
    containers: storage.containers
    networkAcls: storage.networkAcls
  }
}]

module pe 'pe.bicep' =[for storage in st: if (storage.pe.enabled) {
  scope: rgst
  name: 'module-pe-${storage.name}'
  dependsOn: st01
  params: {
    groupIds: storage.pe.groupIds
    location: location
    name: 'pe-${storage.name}'
    privateLinkServiceId: '${rgst.id}/providers/Microsoft.Storage/storageAccounts/${storage.name}'
    subnetid: '${vnet.outputs.vnetid}/subnets/${storage.pe.subnet}'
  }
}]

resource rgaa 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-aa-${envloc2}-01'
  tags: tags
  location: location2
}

module aa 'aa.bicep' = {
  scope: rgaa
  name: 'module-${envloc2}-aa01'
  params: {
    location: location2
    name: 'aa-${envloc2}-01'
    updateSchedules: updateSchedules
  }
}

resource rgvmavail 'Microsoft.Resources/resourceGroups@2021-04-01' = [for vma in virtualMachinesAvail: {
  name: 'rg-${vma.name}'
  location: location
  tags: union(tags, {
    Application: vma.tags.Application
  })
}]

module vmavail 'vmavail.bicep' = [for (vma, i) in virtualMachinesAvail: {
  name: 'module-${vma.name}'
  scope: rgvmavail[i]
  dependsOn: [
    script
    vmlog
  ]
  params: {
    adminPassword: kvexisting.getSecret(vma.name)
    adminUsername: kvexisting.getSecret(keyvault.outputs.username)
    osdiskSizeGB: vma.osdiskSizeGB
    osdiskname: '${vma.name}-OSdisk-${subid}'
    imageReference: vma.imageReference
    location: location
    name: vma.name
    networkinterfaces: vma.networkinterfaces
    tags: union(rgvmavail[i].tags, vma.tags)
    vmSize: vma.vmSize
    vnetid: vnet.outputs.vnetid
    datadisks: vma.datadisks
    osWindows: vma.osWindows
    workspaceId: vmlog.outputs.workspaceId
    workspaceApi: vmlog.outputs.workspaceApi
    backupEnabled: vma.backupEnabled
    policyId: rsv.outputs.rsvpolicy01id
    rsvName: rsv.outputs.rsvname
    rsvRgName: rgrsv.name
  }
}]
