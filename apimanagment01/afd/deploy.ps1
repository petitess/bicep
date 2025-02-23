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

# $Repository = Split-Path -Leaf (git remote get-url origin).TrimEnd('.git')
# $Commit = git rev-parse --short HEAD
$Timestamp = Get-Date -UFormat %s

$DeploymentName = $Environment, $Timestamp | Join-String -Separator _
$TemplateFile = 'main.bicep'
$ParameterFile = "parameters/$Environment.bicepparam"


if ($Command -eq 'validate' -or $Command -eq 'what-if') {
    az deployment sub $Command `
        --name $DeploymentName `
        --subscription $Config.subscription.$Environment `
        --location $Config.location `
        --template-file $TemplateFile `
        --parameters $ParameterFile `
        --no-prompt `
        --output table
}

if ($Command -eq 'create') {
    $result = az stack sub create `
        --name 'frontdoor' `
        --location $Config.location `
        --subscription $Config.subscription.$Environment `
        --template-file $TemplateFile `
        --parameters $ParameterFile `
        --yes `
        --deny-settings-mode none `
        --deny-settings-apply-to-child-scopes `
        --output none `
        --action-on-unmanage 'deleteAll' `


    if ($null -ne $result.ERROR) {
        return 1;
    }
}





