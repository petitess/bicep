$VirtualMachines = Get-AzVM | Where-Object {$_.name -like "vmctxprod*"}

foreach ($Vm in $VirtualMachines) {

New-Item -Path C:\Users\karol\Desktop -ItemType File -Name x$($vm.name).txt

Set-Content -Path "C:\Users\karol\Desktop\x$($vm.name).txt" -Value "This is the server $($vm.name) !"

}
