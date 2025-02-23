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

$Timestamp = Get-Date -UFormat %s

$DeploymentName = $Environment, $Timestamp | Join-String -Separator _
$TemplateFile = 'main.bicep'
$ParameterFile = "parameters/$Environment.bicepparam"

if ($Command -eq 'validate' -or $Command -eq 'what-if' -or $Command -eq 'create') {
    az deployment sub $Command `
        --name $DeploymentName `
        --subscription $Config.subscription.$Environment `
        --location $Config.location `
        --template-file $TemplateFile `
        --parameters $ParameterFile `
        --no-prompt `
        --output table
}

if ($Command -eq 'create' -and $false) {
    az stack sub create `
        --name 'apim' `
        --location $Config.location `
        --subscription $Config.subscription.$Environment `
        --template-file $TemplateFile `
        --parameters $ParameterFile `
        --delete-all true `
        --yes `
        --delete-resources true `
        --deny-settings-mode none `
        --deny-settings-apply-to-child-scopes `
        --output none

    $frontdoorEndpoints = az stack sub show --name "frontdoor" `
        --query 'parameters.config' `
        --output tsv

    $frontdoorEndpoints 
}