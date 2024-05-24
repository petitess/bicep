#!/usr/bin/env pwsh

param (
    #[Parameter(Mandatory)]
    [ValidateScript({ Test-Path $PSScriptRoot/parameters/$_.bicepparam })]
    [String]$Environment = 'dev',

    [ValidateSet('validate', 'what-if', 'create')]
    [String]$Command = 'create'
)

$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot

$Config = Get-Content 'config.json' | ConvertFrom-Json

$Timestamp = Get-Date -UFormat %s

$DeploymentName = $Environment, $Timestamp | Join-String -Separator _
$TemplateFile = 'main.bicep'
$ParameterFile = "parameters/$Environment.bicepparam"

az deployment sub $Command `
    --name $DeploymentName `
    --subscription $Config.subscription.$Environment `
    --location $Config.location `
    --template-file $TemplateFile `
    --parameters $ParameterFile `
    --no-prompt `
    --output json

if ($false) {
    $SubId = ""
    $RgName = "rg-bvault-xxx-dev-sc-01"
    $VaultName = "bvault-xxx-dev-sc-01"
    $PolicyName = "policy-vaulted-disk"
    $InstanceName = "vaulted-stfuncxxxdevsc01"

    az dataprotection backup-vault show --resource-group $RgName --vault-name $VaultName --subscription $SubId
    az dataprotection backup-policy show --name $PolicyName --resource-group $RgName --vault-name $VaultName --subscription $SubId
    az dataprotection backup-instance show --backup-instance-name $InstanceName --resource-group $RgName --vault-name $VaultName --subscription $SubId
}