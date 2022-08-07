targetScope = 'resourceGroup'
//https://www.clounce.com/cloud/azure/azure-functions-with-file-contents-using-bicep
//https://www.gyanblog.com/azure/azure-arm-template-how-create-function-blob-trigger-sendgrid-deployment/
//https://gist.github.com/kdemanuele/a2573b7a5dbc18ea75d0ef6da9ae4eab
param name string
param location string
//change the param name in powersell script below too
var func01name = 'TimerTrigger01'
var tags = resourceGroup().tags

resource funcapp 'Microsoft.Web/sites@2022-03-01' = {
  name: replace(name,'-','')
  location: location
  tags: union(tags, {
    Function: 'FileShare-snapshot'
  })
  kind: 'functionapp'
  identity: {
     type: 'SystemAssigned'
  } 
  properties: {
     enabled: true
     httpsOnly: false
     serverFarmId: hostingPlan.id
     clientAffinityEnabled: false
     siteConfig: {
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
      use32BitWorkerProcess: false
      powerShellVersion: '7.2'
      netFrameworkVersion: 'v6.0'
      ftpsState:  'FtpsOnly'
      http20Enabled: false
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'powershell'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
      }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: uniqueString(resourceGroup().id)
        }
      ]
     }
  }
}
//OPTIONAL:
resource config1 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'web'
  parent: funcapp 
  kind: 'web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
            'Default.htm'
            'Default.html'
            'Default.asp'
            'index.htm'
            'index.html'
            'iisstart.htm'
            'default.aspx'
            'index.php'
    ]
    netFrameworkVersion: 'v6.0'
    powerShellVersion: '7.2'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: funcapp.name
    scmType: 'None'
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
          virtualPath: '/'
          physicalPath: 'site\\wwwroot'
          preloadEnabled: false
      }
  ]
  loadBalancing: 'LeastRequests'
  autoHealEnabled: false
  vnetRouteAllEnabled: false
  vnetPrivatePortsCount: 0
  cors: {
     allowedOrigins: [
      'https://portal.azure.com'
     ]
     supportCredentials: false
  }
  localMySqlEnabled: false
  managedServiceIdentityId: 301
  ipSecurityRestrictions: [
    {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
    }
  ]
  scmIpSecurityRestrictions: [
    {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
    }
]
  scmIpSecurityRestrictionsUseMain: false
  minTlsVersion: '1.2'
  scmMinTlsVersion: '1.2'
  ftpsState: 'FtpsOnly'
  preWarmedInstanceCount: 0
  functionAppScaleLimit: 200
  functionsRuntimeScaleMonitoringEnabled: false
  minimumElasticInstanceCount: 0
  azureStorageAccounts: {}  
  }
   
}

resource func01 'Microsoft.Web/sites/functions@2022-03-01' = {
  name: func01name
  parent: funcapp
  properties: {
    language: 'powershell'
    isDisabled: false
    files: {
      'SubDeploy.ps1': loadTextContent('./SubDeploy.ps1')
      'file.txt': 'This is a test file'
      'run.ps1': '''
      <#
.SYNOPSIS
    Automated process to create on-demand snapshots of an azure files share based on a cron schedule.
.DESCRIPTION
    This script is intended to initiate an on-demand recovery point (snapshot) based on a cron schedule.  Azure Recovery Vault File 
    Share back up is limited to one scheduled recovery point per day. For some organizations, this will not meet their recovery point 
    objectives (RPO). This script is intended to run at an intervale specified in a cron schedule and run on-demand snapshots for 
    additional recovery points.

    Please be aware of the following limitations with Azure File Share Snapshots (Aug, 2021):
        Maximum on-demand backups per day               10
        Maximum total recovery points per file share    200
    Factor in scheduled and on-demand backups to verify total recovery points do not exceed 200
    https://docs.microsoft.com/en-us/azure/backup/azure-file-share-support-matrix

    The cron example below will run at the top of the 15, 18 and 20th hour UTC, Monday through Friday
    Credit https://github.com/atifaziz/NCrontab
    Cron Example:
    0 0 15,18,20 * * 1,2,3,4,5
    - - -        - - -
    | | |        | | |
    | | |        | | +----- day of week (0 - 6) (Sunday=0)
    | | |        | +------- month (1 - 12)
    | | |        +--------- day of month (1 - 31)
    | | +----------- hour (0 - 23 Script uses UTC)
    | +------------- min (0 - 59)
    +------------- sec (0 - 59)
    Link to view the cron expression:
    https://crontab.cronhub.io/
    Link to convert local time to UTC:
    https://www.worldtimebuddy.com/
    
    Use this script for file shares that are configured for backup by the recovery vault.
    This script runs on an Azure Function app.  Use a user assigned managed identity with the backup contributor role 
    assigned to the storage account resource group to create the recovery points.
    Private endpoints will need to be modified when used.

.NOTES
    Script is offered as-is with no warranty, expressed or implied.
    Test it before you trust it
    Author      : Travis Roberts, Ciraltos llc
    Website     : www.ciraltos.com
    Version     :1.0.0.0 Initial Build
#>

# Get the timer parameter
param($TimerTrigger01)

##### Set Variables #####

# Retention Days, the snapshots will expire at the end of the retention period.
# Days must be grater then one (use 1.1 for a one day retention)
$expireDays = 1.1

# Enter the name of the Recovery Vault configured to back up the file shares.
$vaultName = "rsv-infra-dev-01"

# Enter the name of the storage account getting backed up.
$StgActName = "stinfratestsc01"

# Enter one or more Azure File Share Names to be backed up. 
$shareNames = @(
    'fileshare01'
    'fileshare02'
)

##### Execution #####

# Get the expiry date for the share.
$expiryDate = (get-date).AddDays($expireDays)

# Get the vault id
Try {
    $vaultID = (Get-AzRecoveryServicesVault -ErrorAction Stop -Name $vaultName).id 
    Write-Output "The vaultID is: $vaultID"
}
Catch {
    $ErrorMessage = $_.Exception.message
    write-host ('Error getting the vaultID: ' + $ErrorMessage)
    Break
}

Try {
    $rsvContainer = Get-AzRecoveryServicesBackupContainer -ErrorAction Stop -FriendlyName $stgActName -ContainerType AzureStorage -VaultId $vaultID 
    Write-Output "the afsContainer is $rsvContainer"
}
Catch {
    $ErrorMessage = $_.Exception.message
    write-host ('Error getting the backup container: ' + $ErrorMessage)
    Break
}

foreach ($shareName in $shareNames) {
    Try {
        $rsvBkpItem = Get-AzRecoveryServicesBackupItem -ErrorAction Stop -Container $rsvContainer -WorkloadType "AzureFiles" -VaultId $vaultID -FriendlyName $shareName
        $Job = Backup-AzRecoveryServicesBackupItem -ErrorAction Stop -Item $rsvBkpItem -VaultId $vaultID -ExpiryDateTimeUTC $expiryDate
        Write-output "Job data:"
        $Job | Out-String | Write-Host
    }
    Catch {
        $ErrorMessage = $_.Exception.message
        write-host ('Error creating the recovery point: ' + $ErrorMessage)
        Break
    }  
}
      '''
    }
    function_app_id: funcapp.name
    config: {
      bindings: [
        {
            schedule: '0 0 15,18,20 * * 0,1,2,3,4,5'
            name: func01name
            type: 'timerTrigger'
            direction: 'in'
        }
      ]
    }
}
} 

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: replace('${name}st','-','')
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: replace('${name}appi','-','')
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    WorkspaceResourceId: workspace.id
  }
  tags: union(tags,{
    // circular dependency means we can't reference functionApp directly  /subscriptions/<subscriptionId>/resourceGroups/<rg-name>/providers/Microsoft.Web/sites/<appName>"
     'hidden-link:/subscriptions/${subscription().id}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/sites/${replace('${name}appi','-','')}': 'Resource'
  })
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: replace('${name}plan','-','')
  location: location
  tags: tags
  sku: {
    name: 'Y1' 
    tier: 'Dynamic'
  }
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: replace('${name}log','-','')
  location: location
}

module rbac 'rbac.bicep' = {
  scope: subscription()
  name: 'module-${name}-rbac01'
  params: {
    principalId: funcapp.identity.principalId
  }
}
