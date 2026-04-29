main.bicep
```bicep
targetScope = 'subscription'

param param object
param timestamp string = utcNow('dd/MM/yyyy_HH:mm')
param date string
param myvar string
param summertime string
param myarray string

output date string = date
output myvar string = myvar
output summertime string = summertime
output myarray array = split(myarray, ',')
```
lab.bicepparam
```bicepparam
using '../main.bicep'

param param = {
  location: 'SwedenCentral'
  prefix: 'bicep-demo'
  tags: {
    Application: 'Infra'
    Environment: 'Lab'
  }
}

param date = readEnvironmentVariable('MY_DATE', 'empty')
param myvar = readEnvironmentVariable('MY_VAR', 'empty')
param summertime = readEnvironmentVariable('SUMMERTIME', 'empty')
param myarray = readEnvironmentVariable('MY_ARRAY', 'empty')
```
```pwsh
#!/usr/bin/env pwsh

param (
    [Parameter(Mandatory)]
    [String]$Environment,

    [ValidateSet('validate', 'what-if', 'create')]
    [String]$Command = 'create'
)

$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot

$env:MY_DATE = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$env:MY_VAR = "I-LIKE-ICECREAM"
$env:SUMMERTIME = [TimeZoneInfo]::Local.IsDaylightSavingTime((Get-Date))
$env:MY_ARRAY = @('a', 'b', 'c') -join ','
Write-Output $env:MY_DATE
Write-Output $env:MY_VAR
Write-Output $env:SUMMERTIME
Write-Output $env:MY_ARRAY

$ConfigFile = Join-Path '..' 'config' "$Environment.config.json"
$Config = Get-Content $ConfigFile | ConvertFrom-Json

$Repository = Split-Path -Leaf (git remote get-url origin).TrimEnd('.git')
$Commit = git rev-parse --short HEAD
$Timestamp = Get-Date -UFormat %s

$DeploymentName = $Repository, $Environment, $Commit, $Timestamp | Join-String -Separator _
$TemplateFile = 'main.bicep'
$ParameterFile = Join-Path 'parameters' "$Environment.bicepparam"

az deployment sub $Command `
    --name $DeploymentName `
    --subscription $Config.subscription `
    --location $Config.location `
    --template-file $TemplateFile `
    --parameters $ParameterFile `
    --no-prompt `
    --output table
```
pipeline.yml
```yaml
trigger: none

pool:
  vmImage: windows-latest
  # name: vmmgmtprod01

variables:
  azureSubscription: 'sp-sub-lab-01'

parameters:
  - name: environment
    type: string
    default: lab

stages:
  - stage: deploy
    displayName: Deploy Bicep
    jobs:
      - job: iac
        displayName: Validate infrastructure
        steps:
          - task: Bash@3
            displayName: set timezone linux
            condition: eq( variables['Agent.OS'], 'Linux' )
            inputs:
              targetType: 'inline'
              script: | 
                sudo timedatectl set-timezone 'Europe/Stockholm'
          - task: PowerShell@2
            displayName: set timezone windows
            condition: eq( variables['Agent.OS'], 'Windows_NT' )
            inputs:
              targetType: 'inline'
              script: | 
                Set-TimeZone -Id 'Central European Standard Time'
          - task: AzureCLI@2
            displayName: ${{ parameters.environment }}
            inputs:
              azureSubscription: $(azureSubscription)
              scriptType: pscore
              scriptPath: main/deploy.ps1
              arguments: ${{ parameters.environment }} create
```
