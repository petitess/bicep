#!/usr/bin/env pwsh
Connect-AzAccount -Identity

#Runbook content:
New-Item -ItemType "directory" -Name script -Path ..\ 
New-Item -ItemType File -Name script.ps1 -Path ..\script -Value @'
<#
.SYNOPSIS
    Automated process to create on-demand snapshots of an azure files share based on a cron schedule.
.DESCRIPTION
    This script is intended to initiate an on-demand recovery point (snapshot). Azure Recovery Vault File 
    Share back up is limited to one scheduled recovery point per day. For some organizations, this will not meet their recovery point 
    objectives (RPO). 

    Please be aware of the following limitations with Azure File Share Snapshots (Aug, 2021):
        Maximum on-demand backups per day               10
        Maximum total recovery points per file share    200
    Factor in scheduled and on-demand backups to verify total recovery points do not exceed 200
    https://docs.microsoft.com/en-us/azure/backup/azure-file-share-support-matrix
    
    Use this script for file shares that are configured for backup by the recovery vault.
    This script runs on an Azure Automation Account.  Use a user assigned managed identity with the backup contributor role 
    assigned to the storage account resource group to create the recovery points.
    Private endpoints will need to be modified when used.

#>
Connect-AzAccount -Identity

$expireDays = 1.1

# Enter the name of the Recovery Vault configured to back up the file shares.
$vaultName = "rsv-infra-test-01"

# Enter the name of the storage account getting backed up.
$StgActName = "stinfratestsc01"

# Enter one or more Azure File Share Names to be backed up. 
$shareNames = @(
    'fileshare01'
    'fileshare02'
)

$expiryDate = (get-date).AddDays($expireDays)

$vaultID = (Get-AzRecoveryServicesVault -ErrorAction Stop -Name $vaultName).id 

$rsvContainer = Get-AzRecoveryServicesBackupContainer -ErrorAction Stop -FriendlyName $stgActName -ContainerType AzureStorage -VaultId $vaultID 

foreach ($shareName in $shareNames) {
        $rsvBkpItem = Get-AzRecoveryServicesBackupItem -ErrorAction Stop -Container $rsvContainer -WorkloadType "AzureFiles" -VaultId $vaultID -FriendlyName $shareName
        $Job = Backup-AzRecoveryServicesBackupItem -ErrorAction Stop -Item $rsvBkpItem -VaultId $vaultID -ExpiryDateTimeUTC $expiryDate
        Write-output "Snapshot ready"
        $Job | Out-String | Write-Host   
}
'@

Import-AzAutomationRunbook -Name $env:runbookname -ResourceGroupName $env:rgname -AutomationAccountName $env:aaname -Type PowerShell -Published -Path ..\script\script.ps1

