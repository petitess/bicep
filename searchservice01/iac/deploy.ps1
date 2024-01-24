#!/usr/bin/env pwsh

param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $PSScriptRoot/parameters/$_.bicepparam })]
    [String]$Environment,

    [ValidateSet('validate', 'what-if', 'create')]
    [String]$Command = 'create'
)

$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot

$Config = Get-Content 'config.json' | ConvertFrom-Json

#$Repository = Split-Path -Leaf (git remote get-url origin).TrimEnd('.git')
#$Commit = git rev-parse --short HEAD
$Timestamp = Get-Date -UFormat %s

az bicep upgrade

$DeploymentName = $Environment, $Timestamp | Join-String -Separator _
$TemplateFile = 'main.bicep'
$ParameterFile = "parameters/$Environment.bicepparam"

$D = az deployment sub $Command `
    --name $DeploymentName `
    --subscription $Config.subscription.$Environment `
    --location $Config.location `
    --template-file $TemplateFile `
    --parameters $ParameterFile `
    --no-prompt `
    --output json

if ($Command -eq 'create' -and $null -ne $D ) {
    $Deployment = $D | ConvertFrom-Json
    $SqlId = $Deployment.properties.outputs.sqlServerId.value
    $PepIds = az network private-endpoint-connection list --id $SqlId --query "[?properties.privateLinkServiceConnectionState.status=='Pending'].id" -o tsv

    if ($null -ne $PepIds) {
        $PepIds | ForEach-Object {
            $A = az network private-endpoint-connection approve --id $_ --description "Approved by script $(Get-Date -Format "yyyy-MM-dd HH:mm")"
            $Approve = $A | ConvertFrom-Json
            Write-Host "$($Approve.properties.privateLinkServiceConnectionState.status): $($Approve.name)"
        }
    }
}