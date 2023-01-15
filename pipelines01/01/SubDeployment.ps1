$Timestamp = Get-Date -Format 'yyyy-MM-dd_HHmm'
$ConfigFile =  "./iac/config.json"
$Config = Get-Content $ConfigFile | ConvertFrom-Json
$DeploymentName = '{0}_{1}' -f "Infra", $Timestamp
$ParameterFile = "./iac/param.json"

$Arguments = '--name', $DeploymentName, '--subscription', $Config.subscription, '--location', $Config.location, '--template-file', $Config.templateFile, '--parameters', "@$ParameterFile", '--no-prompt', '--output', 'table'

az deployment sub create $Arguments
