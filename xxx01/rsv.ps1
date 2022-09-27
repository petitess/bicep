Get-AzContext
Get-AzSubscription
Set-AzContext -Subscription sub-b3care-prod-01
Get-AzRecoveryServicesVault
#1
$vault = Get-AzRecoveryServicesVault -Name rsv-infra-prod-01 -ResourceGroupName rg-infra-prod-sc-01
#2
Set-AzRecoveryServicesVaultContext -Vault $vault


$backupcontainer = Get-AzRecoveryServicesBackupContainer `
    -ContainerType "AzureVM" `
    -FriendlyName "vmctxprod01"

$item = Get-AzRecoveryServicesBackupItem `
    -Container $backupcontainer `
    -WorkloadType "AzureVM"

Backup-AzRecoveryServicesBackupItem -Item $item
