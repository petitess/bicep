az aks install-cli

az aks get-credentials --resource-group rg-x --name aks-x

kubectl get nodes -o wide

kubectl get pod

az aks nodepool add --resource-group rg-aks-dev-01 --cluster-name aks-dev-01 --name marinerpool --os-sku Mariner --mode System --node-count 1

kubectl node-shell aks-marinerpool-25612674-vmss000000

kubectl debug node/aks-marinerpool-25612674-vmss000000 -it --image=mcr.microsoft.com/dotnet/runtime-deps:6.0

kubectl get pod -o yaml node-debugger-aks-agentpool01-22022661-vmss000000-6zt2x
