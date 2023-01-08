#!/usr/bin/env pwsh

$SecretUser = "adminUsername"

Connect-AzAccount -Identity

$GetSecretUser = Get-AzKeyVaultSecret -VaultName $env:KeyVault -Name $SecretUser 

if ($null -eq $GetSecretUser) {
    $user = ConvertTo-SecureString "azadmin" -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $env:KeyVault -Name $SecretUser -SecretValue $user
}

$VirtualMachines = $env:VirtualMachines | ConvertFrom-Json -AsHashtable
foreach ($Vm in $VirtualMachines) {
    $GetSecretPass = Get-AzKeyVaultSecret -VaultName $env:KeyVault -Name $Vm.name
    if ($null -eq $GetSecretPass) {
        $Bytes = New-Object Byte[] 24
        ([System.Security.Cryptography.RandomNumberGenerator]::Create()).GetBytes($Bytes)
        $Secret = [System.Convert]::ToBase64String($Bytes)
        $Secret = ConvertTo-SecureString $Secret -AsPlainText -Force
        Set-AzKeyVaultSecret -VaultName $env:KeyVault -Name $Vm.name -SecretValue $Secret
    }
}

$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs["adminUsername"] = $SecretUser
