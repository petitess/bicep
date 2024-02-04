param prefix string
param location string
param tags object = resourceGroup().tags
param baseTime string = utcNow('u')
param workspaceId string

param categories object = {
  Checkpoint: true
  Error: true
  Management: true
  Connection: true
  HostRegistration: true
  AgentHealthStatus: true
  NetworkData: true
  SessionHostManagement: true
}

resource vdpool 'Microsoft.DesktopVirtualization/hostPools@2023-10-04-preview' = {
  name: 'vdpool-${prefix}-01'
  location: location
  tags: tags
  properties: {
    hostPoolType: 'Pooled'
    loadBalancerType: 'DepthFirst'
    preferredAppGroupType: 'Desktop'
    publicNetworkAccess: 'Enabled'
    customRdpProperty: '''drivestoredirect:s:;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:0;
    redirectprinters:i:1;devicestoredirect:s:;redirectcomports:i:0;redirectsmartcards:i:1;redirectlocation:i:1;
    usbdevicestoredirect:s:;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:0;
    targetisaadjoined:i:1;enablerdsaadauth:i:1;autoreconnection enabled:i:1;audiocapturemode:i:1;
    redirected video capture encoding quality:i:1;camerastoredirect:s:*;smart sizing:i:1;dynamic resolution:i:1;'''
    startVMOnConnect: true
    validationEnvironment: false
    maxSessionLimit: 15
    registrationInfo: {
      registrationTokenOperation: 'Update'
      expirationTime: dateTimeAdd(baseTime, 'P30D')
    }
    agentUpdate: {
      type: 'Scheduled'
      useSessionHostLocalTime: true
      maintenanceWindows: [
        {
          dayOfWeek: 'Sunday'
          hour: 15
        }
      ]
    }
  }
}

resource vdag 'Microsoft.DesktopVirtualization/applicationGroups@2023-10-04-preview' = {
  name: 'vdag-${prefix}-01'
  location: location
  tags: union(tags, {
      'cm-resource-parent': vdpool.id
    })
  kind: 'Desktop'
  properties: {
    hostPoolArmPath: vdpool.id
    friendlyName: 'Default Desktop'
    applicationGroupType: 'Desktop'
  }
}

resource vdws 'Microsoft.DesktopVirtualization/workspaces@2023-10-04-preview' = {
  name: 'vdws-${prefix}-01'
  location: location
  tags: tags
  properties: {
    publicNetworkAccess: 'Enabled'
    friendlyName: 'workspace-${toLower(tags.Environment)}'
    applicationGroupReferences: [
      vdag.id
    ]
  }
}

resource diagVdpool 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-vdpool-${toLower(tags.Environment)}'
  scope: vdpool
  properties: {
    workspaceId: workspaceId
    logs: [for c in items(categories): {
      category: c.key
      enabled: c.value
    }]
  }
}

resource diagVdag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-vdag-${toLower(tags.Environment)}'
  scope: vdag
  properties: {
    workspaceId: workspaceId
    logs: [for c in items({ Checkpoint: true, Error: true, Management: true}): {
      category: c.key
      enabled: c.value
    }]
  }
}

resource diagVdws 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-vdws-${toLower(tags.Environment)}'
  scope: vdws
  properties: {
    workspaceId: workspaceId
    logs: [for c in items({ Checkpoint: true, Error: true, Management: true, Feed: true }): {
      category: c.key
      enabled: c.value
    }]
  }
}

output registrationInfoToken string = reference(vdpool.id).registrationInfo.token
output name string = vdpool.name
output id string = vdpool.id
