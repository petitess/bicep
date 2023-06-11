param name string
param location string
param tags object = resourceGroup().tags
param nodeRg string
param snetId string

resource aks 'Microsoft.ContainerService/managedClusters@2023-03-02-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Base'
    tier: 'Free'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.25.6'
    dnsPrefix: name
    agentPoolProfiles: [
      {
        name: 'agentpool01'
        count: 1
        vmSize: 'Standard_B4ms'
        osDiskSizeGB: 128
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        maxPods: 110
        type: 'VirtualMachineScaleSets'
        maxCount: 5
        minCount: 1
        enableAutoScaling: true
        orchestratorVersion: '1.25.6'
        enableNodePublicIP: false
        mode: 'System'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        enableFIPS: false
        vnetSubnetID: snetId
      }
    ]
    networkProfile: {
      serviceCidr: '10.255.0.0/16'
      dnsServiceIP: '10.255.0.10'
    }
    linuxProfile: {
      adminUsername: 'azadmin'
      ssh: {
        publicKeys:  [
          {
            keyData: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnF/HtIVyz6YF8AfghNC+DsRUc3OC4EP71G6x2jWgcesFnJ2lgy9ADCaNjjxgKLhmlY/P0/XpuvLGczAguIHTp6o6Q2nI3iFA6KGCfg5qjdTGCeRgPUIM+oqqwcmNc95VZD4Nanb5NSAIsQYna0fVxkQtCn2lPS9D5S+fU8ZlwzuUPnY6sxjqHgAHLILwbJYv5GhqfwNV+zn52Pms7M8Z2FXP04QRw06ymwOplZK2Be+EnPFoHWR8mYD2BuX8MSbmiNVJqgN9MzKokKmTL6O7vMkygsZvk06rpunG5kad/Hb53UcN+0WpeCEIKNn4ksQ+XSp5ijLfatRxrL1gFvSyE/f2PWVwW0zNZL5MI+ijH8kZZ4RLOswUEGdl+sfQe0ZM0jlD1NPhJx/5tPnxQehHg9xruJHOsVgNwmaZJsULAme3kPRv//5TuntM0RciXOtskKcqeBc8t5h/UkblnoT4JRmDsWHmNlU/VwYNIpXUfYJADxi1t2Y02ZrD19umJqxHH1mZR0K2rHI+WUoibcYlEJXlSjVN4/6XMA5+78G8ok5ch5HE37L2Y2dh+PRr0oZ/i8KV4pBXcBV/p96GuEcZ6gf/ov736MeyMfek0+UQacwRNy6NpsnumJH5/xDbW63R6lkmVjBfUS7EhJAbdMpGIG19uKoqnL82PnPAjPwxpew==\n'
          }
        ]
      }
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    addonProfiles: {
      azureKeyvaultSecretsProvider: {
        enabled: false
      }
      azurepolicy: {
        enabled: false
      }
    }
    nodeResourceGroup: nodeRg
    enableRBAC: true
    autoUpgradeProfile: {
      upgradeChannel: 'patch'
    }
    disableLocalAccounts: false
    securityProfile: {}
    storageProfile: {
      diskCSIDriver: {
        enabled: true
        version: 'v1'
      }
      fileCSIDriver: {
        enabled: true
      }
      snapshotController: {
        enabled: true
      }
    }
    oidcIssuerProfile: {
      enabled: false
    }
    workloadAutoScalerProfile: {}
  }
}
