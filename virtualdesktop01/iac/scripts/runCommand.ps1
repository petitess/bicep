#Create folder for profiles and assign permission
$Path = "C:\Users\FXUsers"
$Acl = Get-Acl $Path
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$Acl.SetAccessRule($Ar)
Set-Acl $Path $Acl
#Create custom redirections.xml
$RedirPath = "C:\Windows\FXCustomRedir"
New-Item -ItemType Directory -Path $RedirPath
$RedirXML = @"
<?xml version="1.0"  encoding="UTF-8"?>
<FrxProfileFolderRedirection ExcludeCommonFolders="0">
<Excludes>
</Excludes>
<Includes>
<Include>AppData</Include>
</Includes>
</FrxProfileFolderRedirection>
"@
New-Item -ItemType File -Name "redirections.xml" -Path $RedirPath -Value $RedirXML -Force
#Configure registry
$TestPath = Test-Path $Path
if(!$TestPath) {New-Item -Path $Path -ItemType Directory -Force}
$RegPath = "HKLM:\SOFTWARE\FSLogix\Profiles"

$Values = @(
[pscustomobject]@{name = 'Enabled'; type = "DWord"; value = 1 }
[pscustomobject]@{name = 'DeleteLocalProfileWhenVHDShouldApply'; type = "DWord"; value = 1 }
[pscustomobject]@{name = 'FlipFlopProfileDirectoryName'; type = "DWord"; value = 1 }
[pscustomobject]@{name = 'LockedRetryCount'; type = "DWord"; value = 15 }
[pscustomobject]@{name = 'LockedRetryInterval'; type = "DWord"; value = 1 }
[pscustomobject]@{name = 'ProfileType'; type = "DWord"; value = 0 }
[pscustomobject]@{name = 'ReAttachIntervalSeconds'; type = "DWord"; value = 15 }
[pscustomobject]@{name = 'ReAttachRetryCount'; type = "DWord"; value = 15 }
[pscustomobject]@{name = 'SizeInMBs'; type = "DWord"; value = 10000 }
[pscustomobject]@{name = 'VHDLocations'; type = "String"; value = $Path }
[pscustomobject]@{name = 'VolumeType'; type = "String"; value = "VHDX" }
[pscustomobject]@{name = 'RedirXMLSourceFolder'; type = "String"; value = $RedirPath }
)

$Values | ForEach-Object {
    Set-ItemProperty -Path $regPath -Name $_.name -Value $_.value -Type $_.type | Out-Null
}
#Desktop icons
$RegPathIcons = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
$ValuesIcons = @(
[pscustomobject]@{name = '{20D04FE0-3AEA-1069-A2D8-08002B30309D}'; type = "DWord"; value = 0 }
[pscustomobject]@{name = '{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}'; type = "DWord"; value = 0 }
[pscustomobject]@{name = '{59031a47-3f72-44a7-89c5-5595fe6b30ee}'; type = "DWord"; value = 0 }
[pscustomobject]@{name = '{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}'; type = "DWord"; value = 0 }
)

$ValuesIcons | ForEach-Object {
    Set-ItemProperty -Path $RegPathIcons -Name $_.name -Value $_.value -Type $_.type | Out-Null
}
#Lunch This PC
$RegPathA = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $RegPathA  -Name "LaunchTo" -Value 1 -Type "DWord" | Out-Null

$RegPathB = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
Set-ItemProperty -Path $RegPathB  -Name "NoClose" -Value 1 -Type "DWord" | Out-Null

Set-NetFirewallProfile -Profile Private -Enabled True

$Guest = Get-LocalUser | Where-Object {$_.Name -eq "Guest"}
if($Guest) {Rename-LocalUser -Name "Guest" -NewName "GuestX"}