## A template to deploy Azure compute gallery, VM image definition and VM image version

[Generalize a VM before creating an image](https://learn.microsoft.com/en-us/azure/virtual-machines/generalize)

Run sysprep on vmimage01 first

Then run powershell: Set-AzVm -ResourceGroupName $rgName -Name $vmName -Generalized

Status should be "VM generalized": (Get-AzVM -ResourceGroupName "rg-vmdctest01" -Name "vmdctest01" -Status).Statuses[0].DisplayStatus

Now you can chanage the parameter "sysprepReady" to true







