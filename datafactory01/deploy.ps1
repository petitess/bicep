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

$deployment = az deployment sub $Command `
    --name $DeploymentName `
    --subscription $Config.subscription.$Environment `
    --location $Config.location `
    --template-file $TemplateFile `
    --parameters $ParameterFile `
    --no-prompt `
    --output json
($deployment | ConvertFrom-Json).properties.provisioningState
$MIdentity = ($deployment | ConvertFrom-Json).properties.outputs.mIdPrincipal.value
$GrpObjectId = ($deployment | ConvertFrom-Json).properties.outputs.grpObjectId.value


if ($Command -eq 'create' -and ($deployment | ConvertFrom-Json).properties.provisioningState -eq "Succeeded") {
    $Assigned = az ad group member check --group $GrpObjectId --member-id $MIdentity --output tsv
    if ($Assigned -eq 'False') {
        $Assigned
        #az ad group member add --group $GrpObjectId --member-id $MIdentity
        Write-Output "$MIdentity added to $GrpObjectId"
    }
    else {
        Write-Output "$MIdentity already exists in $GrpObjectId"
    }
}