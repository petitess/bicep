#!/usr/bin/env pwsh

param (
    #[Parameter(Mandatory)]
    # [ValidateScript({ Test-Path $PSScriptRoot/parameters/$_.bicepparam })]
    [String]$Environment = 'dev',

    [ValidateSet('validate', 'what-if', 'create')]
    [String]$Command = 'create'
)

$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot

$Config = Get-Content 'config.json' | ConvertFrom-Json

$Timestamp = Get-Date -UFormat %s

$DeploymentName = 'deploy', $Environment, $Timestamp | Join-String -Separator _
$TemplateFile = 'main.bicep'
$ParameterFile = "parameters/$Environment.bicepparam"

az deployment sub $Command `
    --name $DeploymentName `
    --subscription $Config.subscription.($Environment) `
    --location $Config.location `
    --template-file $TemplateFile `
    --parameters $ParameterFile `
    --no-prompt `
    --output table