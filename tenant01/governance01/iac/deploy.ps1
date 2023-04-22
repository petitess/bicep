#!/usr/bin/env pwsh

param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $PSScriptRoot/parameters/$_.json })]
    [String]$Environment,

    [ValidateSet('validate', 'what-if', 'create')]
    [String]$Command = 'create'
)

$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot

$Config = Get-Content 'config.json' | ConvertFrom-Json

$Repository = Split-Path -Leaf (git remote get-url origin).TrimEnd('.git')
$Commit = git rev-parse --short HEAD
$Timestamp = Get-Date -UFormat %s

$DeploymentName = $Repository, $Environment, $Commit, $Timestamp | Join-String -Separator _
$TemplateFile = 'main.bicep'
$ParameterFile = "parameters/$Environment.json"

az deployment tenant $Command `
    --name $DeploymentName `
    --location $Config.location `
    --template-file $TemplateFile `
    --parameters @$ParameterFile `
    --parameters environment=$Environment `
    --parameters timestamp=$Timestamp `
    --no-prompt `
    --output table


#New-AzTenantDeployment -TemplateFile main.bicep -TemplateParameterFile parameters\prod.json -Location "swedencentral" -Name DeployTenant$(Get-Date -Format 'yyyy-MM-dd') | Select-Object DeploymentName, Location, ProvisioningState, Timestamp, Mode, Outputs
