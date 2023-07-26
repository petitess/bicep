Install and log in
```
az aks install-cli
az aks get-credentials --resource-group rg-aks-dev-01 --name aks-dev-02
```
Get
```
kubectl get nodes -o wide
kubectl get pod
```
Create a new nodepool
```
az aks nodepool add --resource-group rg-aks-dev-01 --cluster-name aks-dev-01 --name marinerpool --os-sku Mariner --mode System --node-count 1
az aks nodepool add --cluster-name aks-dev-02 --resource-group rg-aks-dev-01 --name winnpx --mode User --node-vm-size Standard_B2as_v2 --min-count 1 --max-count 20 --enable-cluster-autoscaler
```
Connect to the node
```
kubectl debug node/aks-marinerpool-25612674-vmss000000 -it --image=mcr.microsoft.com/dotnet/runtime-deps:6.0
```
kubectl get pod -o yaml node-debugger-aks-agentpool01-22022661-vmss000000-6zt2x

az aks update -g rg-aks-dev-01 -n aks-dev-02 --windows-admin-password 1234567890.abc

kubectl node-shell aks-marinerpool-25612674-vmss000000
