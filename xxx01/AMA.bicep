resource workspaceExtension2 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (extensions) {
  parent: vm
  name: 'AzureMonitorWindowsAgent'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.8'
    settings: {
      authentication: {
        managedIdentity: {
          'identifier-name': 'mi_res_id'
          'identifier-value': userAssignedManagedIdentityId
        }
      }
      workspaceId: reference(log, logApi).customerId
      protectedSettings: {
        workspaceKey: listKeys(log, logApi).primarySharedKey
      }
    }

  }
}

https://www.azadvertizer.net/azpolicyadvertizer/637125fd-7c39-4b94-bb0a-d331faf333a9.html?desc=compareJson&left=https%3A%2F%2Fwww.azadvertizer.net%2Fazpolicyadvertizerjson%2F637125fd-7c39-4b94-bb0a-d331faf333a9_1.0.0.json&right=https%3A%2F%2Fwww.azadvertizer.net%2Fazpolicyadvertizerjson%2F637125fd-7c39-4b94-bb0a-d331faf333a9_1.1.0.json

https://www.azadvertizer.net/azpolicyadvertizer/a4034bc6-ae50-406d-bf76-50f4ee5a7811.html?desc=compareJson&left=https%3A%2F%2Fwww.azadvertizer.net%2Fazpolicyadvertizerjson%2Fa4034bc6-ae50-406d-bf76-50f4ee5a7811_2.0.0.json&right=https%3A%2F%2Fwww.azadvertizer.net%2Fazpolicyadvertizerjson%2Fa4034bc6-ae50-406d-bf76-50f4ee5a7811_2.1.0.json

https://docs.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-migration

https://docs.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-manage?tabs=ARMAgentPowerShell%2CPowerShellWindows%2CPowerShellWindowsArc%2CCLIWindows%2CCLIWindowsArc#virtual-machine-extension-details

https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/azure-monitor/agents/resource-manager-agent.md

https://azsec.azurewebsites.net/2021/01/18/multi-homing-logging-with-new-azure-monitor-agent/

https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/azure-monitor/agents/azure-monitor-agent-troubleshoot-windows-vm.md

https://docs.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-manage?tabs=ARMAgentPowerShell%2CPowerShellWindows%2CPowerShellWindowsArc%2CCLIWindows%2CCLIWindowsArc

