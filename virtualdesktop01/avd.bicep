targetScope = 'resourceGroup'

param name string
param location string
param baseTime string = utcNow('u')

resource avdpool 'Microsoft.DesktopVirtualization/hostPools@2022-04-01-preview' = {
  name: '${name}01'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hostPoolType:  'Pooled'
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
    personalDesktopAssignmentType: 'Automatic'  
    maxSessionLimit: 5
    validationEnvironment: false
    ring: null 
    startVMOnConnect: false
    agentUpdate: {
      type: 'Scheduled'
      maintenanceWindowTimeZone: 'W. Europe Standard Time'
      maintenanceWindows: [
        {
          dayOfWeek: 'Wednesday'
          hour: 5
        }
      ]
    }
    registrationInfo: {
      registrationTokenOperation: 'Update'
      expirationTime:  dateTimeAdd(baseTime, 'P15D')
      token: null
    }
  }
}

resource plan 'Microsoft.DesktopVirtualization/scalingPlans@2022-04-01-preview' = {
  name: 'scaling01'
  location: location
  properties: {
    timeZone: 'W. Europe Standard Time'
    hostPoolType: 'Pooled'
    schedules: [
      {
        name: 'schedule01'
        daysOfWeek: [
          'Monday'
          'Tuesday'
          'Wednesday'
          'Thursday'
          'Friday'
        ]
        rampUpLoadBalancingAlgorithm: 'BreadthFirst'
        rampUpMinimumHostsPct: 20
        rampUpCapacityThresholdPct: 60
        peakLoadBalancingAlgorithm: 'BreadthFirst'
        rampDownLoadBalancingAlgorithm: 'BreadthFirst'
        rampDownMinimumHostsPct: 10
        rampDownCapacityThresholdPct: 90
        rampDownForceLogoffUsers: false
        rampDownWaitTimeMinutes: 30
        rampDownNotificationMessage: 'You will be logged off in 30 min'
        rampUpStartTime: {
          minute: 0
          hour: 7
        }
        peakStartTime: {
          minute: 0
          hour: 8
        }
        rampDownStartTime: {
          minute: 0
          hour: 20
        }
        offPeakStartTime: {
          minute: 0
          hour: 21
        }

      }
    ]
  }
}

resource applicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2022-04-01-preview' = {
  name: '${name}-appgrp'
  location: location
  properties: {
    applicationGroupType: 'Desktop'
    description: 'Deskop Application Group created through Abri Deploy process.'
    hostPoolArmPath: resourceId('Microsoft.DesktopVirtualization/hostpools', avdpool.name)
  }
}

resource workspace 'Microsoft.DesktopVirtualization/workspaces@2022-04-01-preview' = {
  name: '${applicationGroup.name}-ws01'
  location: location
  properties: {
    applicationGroupReferences:[
      resourceId('Microsoft.DesktopVirtualization/applicationgroups/', applicationGroup.name)
    ]
  }
}

output hpname string = avdpool.name
output appgrpname string = applicationGroup.name
