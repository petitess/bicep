targetScope = 'subscription'

param tags object
param env string
param location string = deployment().location
param utc string = utcNow()
param date string = utcNow('yyyy-MM-dd')

var unique = take(uniqueString(subscription().subscriptionId), 3)
var prefix = toLower('${unique}-${env}')

func name(res string, instance string) string => '${res}-${prefix}-${instance}'

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: name('rg-st-cost', '01')
  location: location
  tags: tags
}

module stM 'st.bicep' = {
  scope: rg
  params: {
    name: 'stcostmgmtabc001'
    location: location
    publicAccess: 'Enabled'
    containers: [
      'cost'
    ]
  }
}

resource cost_actual 'Microsoft.CostManagement/exports@2025-03-01' = {
  name: 'bicep-cost-actual'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    definition: {
      timeframe: 'MonthToDate'
      type: 'ActualCost'
    }
    deliveryInfo: {
      destination: {
        container: 'cost'
        resourceId: stM.outputs.id
        rootFolderPath: 'exports'
      }
    }
    compressionMode: 'none'
    format: 'Csv'
    dataOverwriteBehavior: 'OverwritePreviousReport'
    schedule: {
      status: 'Active'
      recurrence: 'Daily'
      recurrencePeriod: {
        from: '${date}T00:00:00Z'
        to: dateTimeAdd(utc, 'P20Y')
      }
    }
  }
}

resource cost_usage 'Microsoft.CostManagement/exports@2025-03-01' = {
  name: 'bicep-cost-usage'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    definition: {
      timeframe: 'MonthToDate'
      type: 'Usage'
    }
    deliveryInfo: {
      destination: {
        container: 'cost'
        resourceId: stM.outputs.id
        rootFolderPath: 'exports'
      }
    }
    compressionMode: 'none'
    format: 'Csv'
    dataOverwriteBehavior: 'OverwritePreviousReport'
    schedule: {
      status: 'Active'
      recurrence: 'Daily'
      recurrencePeriod: {
        from: '${date}T00:00:00Z'
        to: dateTimeAdd(utc, 'P20Y')
      }
    }
  }
}

resource cost_amortized 'Microsoft.CostManagement/exports@2025-03-01' = {
  name: 'bicep-cost-amortized'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    definition: {
      timeframe: 'MonthToDate'
      type: 'AmortizedCost'
    }
    deliveryInfo: {
      destination: {
        container: 'cost'
        resourceId: stM.outputs.id
        rootFolderPath: 'exports'
      }
    }
    compressionMode: 'none'
    format: 'Csv'
    dataOverwriteBehavior: 'OverwritePreviousReport'
    schedule: {
      status: 'Active'
      recurrence: 'Daily'
      recurrencePeriod: {
        from: '${date}T00:00:00Z'
        to: dateTimeAdd(utc, 'P20Y')
      }
    }
  }
}

output utc string = utc
