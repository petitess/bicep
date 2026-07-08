## Configure Custom Logs
Create a table in log analytics and data collection rule.

Assign Monitoring Metrics Publisher to the service principal.

Create an alert.

```bicep
targetScope = 'resourceGroup'

param name string
param location string
param rbac ({
  role: ('Log Analytics Contributor' | 'Log Analytics Reader' | 'Contributor' | 'Reader' | 'Monitoring Metrics Publisher')
  principalId: string
  principalType: string?
})[] = [{
  principalId: 'xyz-123'
  role: 'Monitoring Metrics Publisher'
}]
param env string
param actionGroupId string?

var tags = resourceGroup().tags
var sku = 'PerGB2018'
var retention = 90

var rolesList = {
  'Log Analytics Contributor': '92aaf0da-9dab-42b6-94a3-d43ce8d16293'
  'Log Analytics Reader': '73c42c96-874c-492b-b04d-ab87d138a893'
  Contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  'Monitoring Metrics Publisher': '3913510d-42f4-4e42-8a64-420c390055eb'
}
var my_table = 'mysystem'
var dataStructure = [
  {
    name: 'TimeGenerated'
    type: 'datetime'
  }
  {
    name: 'LogTime'
    type: 'string'
  }
  {
    name: 'BatchSuccess'
    type: 'string'
  }
  {
    name: 'ApplicationName'
    type: 'string'
  }
  {
    name: 'BatchScheduleId'
    type: 'string'
  }
  {
    name: 'BatchDisplayName'
    type: 'string'
  }
  {
    name: 'BatchType'
    type: 'string'
  }
  {
    name: 'VmName'
    type: 'string'
  }
  {
    name: 'Message'
    type: 'string'
  }
]

resource workspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retention
  }
}

resource table 'Microsoft.OperationalInsights/workspaces/tables@2025-02-01' = {
  parent: workspace
  name: '${my_table}_CL'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: '${my_table}_CL'
      columns: dataStructure
    }
    retentionInDays: 30
  }
}

resource alert3 'Microsoft.Insights/scheduledQueryRules@2026-03-01' = {
  name: 'BatchStop-vmsys${env}03'
  location: location
  tags: tags
  properties: {
    enabled: true
    displayName: 'BatchStop-vmsys${env}03'
    description: 'BatchStop-vmsys${env}03'
    scopes: [
      workspace.id
    ]
    actions: {
      actionGroups: [
        actionGroupId
      ]
    }
    criteria: {
      allOf: [
        {
          query: $'''
mysystem_CL
| where VmName == "vmsys${env}03"
| where BatchSuccess contains "false" or Message contains "error"
| distinct LogTime, ApplicationName, BatchDisplayName, BatchScheduleId , BatchSuccess, VmName, Message
          '''
          threshold: 0
          operator: 'GreaterThan'
          timeAggregation: 'Count'
          failingPeriods: {
            minFailingPeriodsToAlert: 1
            numberOfEvaluationPeriods: 1
          }
          dimensions: [
            {
              name: 'Message'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
        }
      ]
    }
    evaluationFrequency: 'PT5M'
    severity: 3
    windowSize: 'PT5M'
    autoMitigate: false
  }
}

resource dcrend 'Microsoft.Insights/dataCollectionEndpoints@2024-03-11' = {
  name: 'dce-${env}-01'
  location: location
  tags: tags
  properties: {
    configurationAccess: {}
    logsIngestion: {}
    metricsIngestion: {}
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

resource dcr 'Microsoft.Insights/dataCollectionRules@2024-03-11' = {
  name: 'dcr-${env}-01'
  location: location
  tags: tags
  properties: {
    dataCollectionEndpointId: dcrend.id
    streamDeclarations: {
      'Custom-${my_table}_CL': {
        columns: dataStructure
      }
    }
    dataSources: {}
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: resourceId('Microsoft.OperationalInsights/workspaces', workspace.name)
          name: workspace.name
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Custom-${my_table}_CL'
        ]
        destinations: [
          workspace.name
        ]
        transformKql: 'source'
        outputStream: 'Custom-${my_table}_CL'
      }
    ]
  }
}

resource rbacR 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for r in rbac: if (rbac != []) {
    name: guid(subscription().id, r.principalId, r.role, resourceGroup().id)
    properties: {
      principalId: r.principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleAssignments', rolesList[r.role])
      principalType: r.?principalType ?? 'ServicePrincipal'
    }
  }
]
```
## Send data to log analytics
You can create a local script on a virtual machine and create a scheduled task.

In the body variable add custom properties.

Logs Ingestion Url is located in Data collection endpoint.

Immutable ID is located in Data collection rule.

```powershell
Connect-AzAccount -Identity
$hide = Set-AzContext -Subscription "sub-test-01"
$ErrorActionPreference = 'Continue'

$Date = Get-Date -Format "yyyyMMdd"
$Logs = Get-Content "C:\CompnanyX\sysBatch\Log\log-$Date.json" | ConvertFrom-Json | Where-Object { ($_.'@mt' -like "*BatchSuccess: False") -or ($_.'@mt' -like "*error*") }

$New = (Get-Content "C:\CompnanyX\sysBatch\Log\log-$Date.json" | ConvertFrom-Json | Where-Object { ($_.'@mt' -like "*BatchSuccess: False") -or ($_.'@mt' -like "*error*") }).Length
$Old = (Get-Content "C:\Mgmt\Scripts\SendSysLogsTest.json" | ConvertFrom-Json | Where-Object { ($_.'@mt' -like "*BatchSuccess: False") -or ($_.'@mt' -like "*error*") }).Length

$DcrImmutableId = 'dcr-e0e0dbed123456789a0b2c7650defe72'
$DceIngestionUrl = 'https://dce-test-01-1234.swedencentral-1.ingest.monitor.azure.com'
$MyTableName = 'mysystem'
$URL = "$DceIngestionUrl/dataCollectionRules/$DcrImmutableId/streams/Custom-$($MyTableName)_CL?api-version=2023-01-01"
$SecureToken = $((Get-AzAccessToken -ResourceUrl "https://monitor.azure.com").Token)
$Token = [Runtime.InteropServices.Marshal]::PtrToStringUni(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureToken)
)

$headers = @{
    "Authorization" = "Bearer $Token"
    "Content-type"  = "application/json; charset=utf-8"
}

if ($New -ne $Old) {
    Write-Output "Sending logs"
    $Logs | ForEach-Object {
        $Message = @"
$($_.'@x')
"@
        $Body = ConvertTo-Json @(@{
                TimeGenerated    = Get-Date -Format "yyyy-MM-dd-HH-mm"
                LogTime          = $_."@t"
                BatchSuccess     = $_."@mt"
                ApplicationName  = $_.ApplicationName
                BatchScheduleId  = $_.BatchScheduleId
                BatchDisplayName = $_.BatchDisplayName
                BatchType        = $_.BatchType
                VmName           = "vmsystest05"
                Message          = $Message
            })
        Invoke-RestMethod -Uri $URL -Method Post -Headers $headers -Body $Body
    }
    Copy-Item -Path "C:\CompnanyX\sysBatch\Log\log-$Date.json" -Destination "C:\Mgmt\Scripts\SendSysLogsTest.json" -Force
}
else {
    Write-Output "The same"
}
```
### Settings for a scheduled task
General:
- Run as: SYSTEM
- Run whether ueser is logged on or not
  
Triggers:
- Recure every 1 days
- Repeat task every 5 minutes for a duration of Indefinitely
  
Actions:
- Program/script: powershell.exe
- Add arguments: C:\Mgmt\Scripts\SendSysLogs
  
Settings:
- Allow task to be run on demand
