targetScope = 'resourceGroup'

param vmname string
param associationName string
param DataWinId string
param DataLinuxId string
param extensions bool
param publisher string

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' existing = {
  name: vmname
}

resource associationWin 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = if (extensions || publisher == 'canonical') {
  name: associationName
  scope: vm
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this windows VMs.'
    dataCollectionRuleId: extensions ? DataWinId : DataLinuxId
  }
}
