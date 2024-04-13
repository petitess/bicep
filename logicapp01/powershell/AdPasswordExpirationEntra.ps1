#PUT THIS FILE ON A MGMT SERVER
#WORKS WITH LOGIC APP
#9223372036854775807 = password never expires
#Assign Storage Table Data Contributor for VM's system assigned identity

#INSTALL MODLUES:
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force

Connect-AzAccount -Identity

# Step 1, Set variables
# Enter Table Storage location data 
$storageAccountName = 'stlogicpassdev01'
$tableName = 'userpasswordexpiration'
$partitionKey = 'passwordexpiration'
$users = @()

#Clear table
$Token = (Get-AzAccessToken -ResourceUrl 'https://storage.azure.com/').Token
$URL = "https://$storageAccountName.table.core.windows.net/$tableName"
$Date = Get-Date (Get-Date).ToUniversalTime() -Format 'R'
$headers = @{
    "Authorization" = "Bearer $Token"
    "x-ms-date"     = $Date
    "x-ms-version"  = "2020-04-08"
    "Accept"        = "application/json;odata=fullmetadata"
}
$I = Invoke-RestMethod -Method GET -URI $URL -Headers $headers

$I.value.'odata.id' | ForEach-Object {
    $URL = $_
    $Date = Get-Date (Get-Date).ToUniversalTime() -Format 'R'
    $headers = @{
        "Authorization" = "Bearer $Token"
        "x-ms-date"     = $Date
        "Content-type"  = "application/json"
        "x-ms-version"  = "2020-04-08"
        "Accept"        = "application/json;odata=fullmetadata"
        "If-Match"      = "*"
    }
    $I = Invoke-RestMethod -Method Delete -URI $URL -Headers $headers #-Body $Body
}

#Create verification row
$URL = "https://$storageAccountName.table.core.windows.net/$tableName"
$Date = Get-Date (Get-Date).ToUniversalTime() -Format 'R'
$Body = ConvertTo-Json @{
    "PartitionKey"      = $partitionKey
    "RowKey"            = ([guid]::NewGuid().tostring())
    "WriteTime"         = (Get-Date -Format "yyyyMMdd")
    "UserPrincipalName" = "Success"
    "Name"              = "Success"
    "Mail"              = "Success"
    "ExpiryDate"        = "Success"
}
$headers = @{
    "Authorization"  = "Bearer $Token"
    "x-ms-date"      = $Date
    "Content-type"   = "application/json"
    "Content-Length" = $Body.Length
    "x-ms-version"   = "2020-04-08"
    "Accept"         = "application/json;odata=fullmetadata"
}
$I = Invoke-RestMethod -Method POST -URI $URL -Headers $headers -Body $Body

# Step 3, get the data 
$users = Get-ADUser -filter { Enabled -eq $True -and PasswordNeverExpires -eq $False } -Properties UserPrincipalName, msDS-UserPasswordExpiryTimeComputed, mail, name | `
    Where-Object { $_."msDS-UserPasswordExpiryTimeComputed" -notmatch "92233720" } | `
    Where-Object { [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") -lt (Get-Date).AddDays(7) -and [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") -ge (Get-Date) -and $null -ne $_.mail } | `
    Select-Object -Property "Name", "UserPrincipalName", "mail", @{Name = "ExpiryDate"; Expression = { [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") } }

foreach ($user in $users) {

    #Create user row
    $URL = "https://$storageAccountName.table.core.windows.net/$tableName"
    $Date = Get-Date (Get-Date).ToUniversalTime() -Format 'R'
    $Body = ConvertTo-Json @{
        "PartitionKey"      = $partitionKey
        "RowKey"            = ([guid]::NewGuid().tostring())
        "WriteTime"         = (Get-Date -Format "yyyyMMdd")
        "UserPrincipalName" = $user.UserPrincipalName
        "Name"              = $user.Name
        "Mail"              = $user.mail
        "ExpiryDate"        = $user.ExpiryDate.ToString("yyyy-MM-dd")
    }
    $headers = @{
        "Authorization"  = "Bearer $Token"
        "x-ms-date"      = $Date
        "Content-type"   = "application/json"
        "Content-Length" = $Body.Length
        "x-ms-version"   = "2020-04-08"
        "Accept"         = "application/json;odata=fullmetadata"
    }
    $I = Invoke-RestMethod -Method POST -URI $URL -Headers $headers -Body $Body
}

New-Item -Path "C:\B3\AdPasswordExpiration.txt" -Value "AdPasswordExpiration.ps1 run successfully: $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -Force