Set-Location $PSScriptRoot

$Timestamp = Get-Date -Format "dd-MMMM-y"
$SubId = "2d9f44ea-e3df-4ea1-b956-8c7a43b119a0"
$Location = "swedencentral"
$TemplateFile = "..\main.bicep"

az deployment sub create `
    --name $Timestamp `
    --subscription $SubId `
    --location $Location `
    --template-file $TemplateFile `
    --no-prompt `
    --output table
    #--parameters $ParameterFile `