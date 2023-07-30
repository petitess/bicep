#### Install and log in
```
az aks install-cli
az aks get-credentials --resource-group rg-aks-dev-01 --name aks-dev-01
```
#### Get
```
kubectl get nodes -o wide
kubectl get pod
```
#### Create a new nodepool
```
az aks nodepool add --resource-group rg-aks-dev-01 --cluster-name aks-dev-01 --name marinerpool --os-sku Mariner --mode System --node-count 1
az aks nodepool add --cluster-name aks-dev-02 --resource-group rg-aks-dev-01 --name winnpx --mode User --node-vm-size Standard_B2as_v2 --min-count 1 --max-count 20 
az aks nodepool add --name ephemeral --cluster-name aks-dev-01 --resource-group rg-aks-dev-01 -s Standard_B4ms --node-osdisk-type Ephemeral --node-osdisk-size 30 --node-count 1
az aks nodepool add --name managed --cluster-name aks-dev-01 --resource-group rg-aks-dev-01 -s Standard_B4ms --node-osdisk-type Managed --node-osdisk-size 30 --node-count 1 --enable-cluster-autoscaler --min-count 1 --max-count 20
az aks nodepool add --name gpu --cluster-name aks-dev-01 --resource-group rg-aks-dev-01 -s Standard_D2ads_v5 --node-taints sku=gpu:NoSchedule --node-osdisk-size 30 --node-count 1 --enable-cluster-autoscaler --min-count 1 --max-count 20 
```
#### Connect to the node
```
kubectl debug node/aks-marinerpool-25612674-vmss000000 -it --image=mcr.microsoft.com/dotnet/runtime-deps:6.0
```
kubectl get pod -o yaml node-debugger-aks-agentpool01-22022661-vmss000000-6zt2x

az aks update -g rg-aks-dev-01 -n aks-dev-02 --windows-admin-password 1234567890.abc

kubectl node-shell aks-marinerpool-25612674-vmss000000

------------
#### Deploy the application
https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-bicep?tabs=azure-cli

vim azure-vote.yaml  

To save: :wq!

kubectl apply -f azure-vote.yaml 