#PUT THIS FILE ON A MGMT SERVER
#WORKS WITH LOGIC APP
##9223372036854775807 = password never expires

#INSTALL MODLUES:
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force
#Install-Module AzTable -Scope AllUsers -Force

# Step 1, Set variables
# Enter Table Storage location data 
$storageAccountName = 'st34525434drfg'
$tableName = 'userpasswordexpiration'
$sasToken = '?sv=2021-06-08&ss=t&srt=sco&sp=rwdlacu&se=2032-11-24T21:30:05Z&st=2022-11-24T13:30:05Z&spr=https&sig=inxxxxxxxxxxxxxU9k%3D'
$dateTime = get-date
$partitionKey = 'passwordexpiration'
$users = @()

# Step 2, Connect to Azure Table Storage
$storageCtx = New-AzStorageContext -StorageAccountName $storageAccountName -SasToken $sasToken
$table = (Get-AzStorageTable -Name $tableName -Context $storageCtx).CloudTable


#Get-AzTableRow -Table $Table -ColumnName "WriteTime" -Value $dateTime.ToString("yyyyMMdd") -Operator NotEqual | Remove-AzTableRow -Table $Table
Get-AzTableRow -Table $Table | Remove-AzTableRow -Table $Table


Add-AzTableRow -table $table -partitionKey $partitionKey -rowKey ([guid]::NewGuid().tostring()) -property @{
 'WriteTime' = $dateTime.ToString("yyyyMMdd")
 'UserPrincipalName' = 'Success'
 'Name' = 'Success'
 'Mail' = 'Success'
 'ExpiryDate' = 'Success'
 } | Out-Null

# Step 3, get the data 
$users = Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -Properties UserPrincipalName, msDS-UserPasswordExpiryTimeComputed, mail, name | `
Where-Object {$_."msDS-UserPasswordExpiryTimeComputed" -notmatch "92233720"} | `
Where-Object {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") -lt (Get-Date).AddDays(7) -and [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") -ge (Get-Date) -and $null -ne $_.mail} | `
Select-Object -Property "Name", "UserPrincipalName","mail",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}

foreach ($user in $users) {
 Add-AzTableRow -table $table -partitionKey $partitionKey -rowKey ([guid]::NewGuid().tostring()) -property @{
 'WriteTime' = $dateTime.ToString("yyyyMMdd")
 'UserPrincipalName' = $user.UserPrincipalName
 'Name' = $user.Name
 'Mail' = $user.mail
 'ExpiryDate' = $user.ExpiryDate.ToString("yyyy-MM-dd")
 } | Out-Null
}

New-Item -Path "C:\B3\AdPasswordExpiration$(Get-Date -Format 'yyyy-MM-dd').txt" -Value "AdPasswordExpiration.ps1 run successfully: $(Get-Date -Format 'yyyy-MM-dd')" -Force
$temp = (Get-Date).AddDays(-1)
if (Test-Path "C:\B3\AdPasswordExpiration$(Get-Date $Temp -Format 'yyyy-MM-dd').txt") {
Remove-Item -Path "C:\B3\AdPasswordExpiration$(Get-Date $Temp -Format 'yyyy-MM-dd').txt"
}