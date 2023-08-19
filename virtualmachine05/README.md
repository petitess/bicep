## A template to deploy Azure compute gallery, VM image definition and VM image version

[Generalize a VM before creating an image](https://learn.microsoft.com/en-us/azure/virtual-machines/generalize)

Create a VM manually and run sysprep first

``cd %windir%\system32\sysprep``

``sysprep.exe /oobe /generalize /shutdown``

Then run powershell: 

``Set-AzVm -ResourceGroupName "rg-vmimage01" -Name "vmimage01" -Generalized``

Status should be "VM generalized":

``(Get-AzVM -ResourceGroupName "rg-gal-dev-01" -Name "vm1" -Status).Statuses[0].DisplayStatus``

Create a image version

Now you can chanage the parameter "sysprepReady" to true
