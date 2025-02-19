#!/usr/bin/env pwsh

param (
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

az deployment tenant $Command `
    --name $DeploymentName `
    --location $Config.location `
    --template-file $TemplateFile `
    --parameters environment=$Environment `
    --no-prompt `
    --output table