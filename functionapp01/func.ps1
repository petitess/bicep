Invoke-RestMethod -Uri "http://localhost:7071/api/test-ai-foundry" -Method Post -Body $body

$body = @"
{
    "data": {
        "essentials": {
            "region": "westeurope",
            "alertId": "/subscriptions/fca54459-0e45-471d-918a-7059ac54e7ee/providers/Microsoft.AlertsManagement/alerts/632063ae-ef07-30d8-3908-fe306941000e",
            "severity": "Sev1",
            "alertRule": "Backup Failure",
            "signalType": "Log",
            "description": "First full backup is missing for this datasource.",
            "firedDateTime": "2026-03-13T11:56:13.9392346Z",
            "originAlertId": "2516288980568183370_0_46882796573241193411846827691315511505azureworkloadusererrorparentfullbackupmissinglog",
            "alertTargetIDs": [
                "/subscriptions/fca54459-0e45-471d-918a-7059ac54e7ee/resourcegroups/rg-infrastructure-prod-rsv/providers/microsoft.recoveryservices/vaults/rsv-infra-prod-01"
            ],
            "monitorCondition": "Fired",
            "essentialsVersion": "1.0",
            "investigationLink": "https://portal.azure.com/#view/Microsoft_Azure_Monitoring_Alerts/Issue.ReactView/alertId/%2fsubscriptions%2ffca54459-0e45-471d-918a-7059ac54e7ee%2fresourceGroups%2frg-infrastructure-prod-rsv%2fproviders%2fMicrosoft.AlertsManagement%2falerts%2f632063ae-ef07-30d8-3908-fe306941000e",
            "monitoringService": "Azure Backup",
            "configurationItems": [
                "rsv-infra-prod-01"
            ],
            "targetResourceType": "microsoft.recoveryservices/vaults",
            "alertContextVersion": "1.0",
            "targetResourceGroup": "rg-infrastructure-prod-rsv"
        },
        "alertContext": {
            "category": "Jobs",
            "sourceId": "/subscriptions/fca54459-0e45-471d-918a-7059ac54e7ee/resourceGroups/rg-infrastructure-prod-legacy-sql/providers/Microsoft.Compute/virtualMachines/vm-sql-prod-02/providers/Microsoft.RecoveryServices/backupProtectedItem/SQLDataBase;MSSQLSERVER;Clara_migtotest_20260313",
            "sourceType": "SQLDataBase",
            "extendedInfo": {
                "jobId": "88df0be3-7c77-46c9-bfc2-fb92e3b1918a",
                "possibleCauses": null,
                "occurrenceCount": 1,
                "recommendedActions": "In case of a scheduled backup, ignore this error as a full backup will be triggered automatically by the service. However, if you want to take an ad-hoc backup right now, trigger a full backup first to fix this issue. For troubleshooting instructions, see https://aka.ms/AB-usererrorparentfullbackupmissing"
            },
            "affectedItems": "/subscriptions/fca54459-0e45-471d-918a-7059ac54e7ee/resourceGroups/rg-infrastructure-prod-legacy-sql/providers/Microsoft.Compute/virtualMachines/vm-sql-prod-02/providers/Microsoft.RecoveryServices/backupProtectedItem/SQLDataBase;MSSQLSERVER;Clara_migtotest_20260313",
            "sourceVersion": "VMAppContainer",
            "protectedItemId": "/subscriptions/fca54459-0e45-471d-918a-7059ac54e7ee/resourceGroups/rg-Infrastructure-Prod-rsv/providers/Microsoft.RecoveryServices/vaults/rsv-infra-prod-01/backupFabrics/Azure/protectionContainers/VMAppContainer;Compute;rg-infrastructure-prod-legacy-sql;vm-sql-prod-02/protectedItems/SQLDataBase;MSSQLSERVER;Clara_migtotest_20260313",
            "linkedResourceId": "/subscriptions/fca54459-0e45-471d-918a-7059ac54e7ee/resourceGroups/rg-infrastructure-prod-legacy-sql/providers/Microsoft.Compute/virtualMachines/vm-sql-prod-02",
            "alertVersionNumber": "V2020_10",
            "linkedResourceName": "vm-sql-prod-02",
            "formattedSourceType": "AzureVmSQL",
            "firstLevelContainerId": "Compute;rg-infrastructure-prod-legacy-sql;vm-sql-prod-02",
            "secondLevelContainerId": null
        },
        "customProperties": null
    },
    "schemaId": "azureMonitorCommonAlertSchema"
}
"@
(Invoke-RestMethod -Uri "http://localhost:7071/api/summarize-json" -Method Post -Body $body) | ConvertTo-Json

$body = @"
{
    "data": {
        "essentials": {
            "alertId": "/subscriptions/fca54459-0e45-471d-918a-7059ac54e7ee/providers/Microsoft.AlertsManagement/alerts/6558a4fe-e768-4cf0-befc-8b1909f2f000",
            "severity": "Sev2",
            "alertRule": "sqlja-elasticjobprod-failed",
            "signalType": "Metric",
            "alertRuleID": "/subscriptions/fca54459-0e45-471d-918a-7059ac54e7ee/resourcegroups/rg-infrastructure-prod-sql/providers/Microsoft.Insights/metricAlerts/sqlja-elasticjobprod-failed",
            "description": "",
            "firedDateTime": "2026-03-15T07:19:50.9186641Z",
            "originAlertId": "fca54459-0e45-471d-918a-7059ac54e7ee_rg-infrastructure-prod-sql_Microsoft.Insights_metricAlerts_sqlja-elasticjobprod-failed_1081273872",
            "alertTargetIDs": [
                "/subscriptions/fca54459-0e45-471d-918a-7059ac54e7ee/resourcegroups/rg-infrastructure-prod-sql/providers/microsoft.sql/servers/sql-infra-prod-01/jobagents/sqlja-elasticjobprod"
            ],
            "monitorCondition": "Fired",
            "essentialsVersion": "1.0",
            "investigationLink": "https://portal.azure.com/#view/Microsoft_Azure_Monitoring_Alerts/Issue.ReactView/alertId/%2fsubscriptions%2ffca54459-0e45-471d-918a-7059ac54e7ee%2fresourceGroups%2frg-infrastructure-prod-sql%2fproviders%2fMicrosoft.AlertsManagement%2falerts%2f6558a4fe-e768-4cf0-befc-8b1909f2f000",
            "monitoringService": "Platform",
            "configurationItems": [
                "sqlja-elasticjobprod"
            ],
            "targetResourceType": "microsoft.sql/servers/jobagents",
            "alertContextVersion": "1.0",
            "targetResourceGroup": "rg-infrastructure-prod-sql"
        },
        "alertContext": {
            "condition": {
                "allOf": [
                    {
                        "operator": "GreaterThan",
                        "threshold": "0",
                        "dimensions": [],
                        "metricName": "elastic_jobs_failed",
                        "metricValue": 1,
                        "webTestName": null,
                        "metricNamespace": "Microsoft.Sql/servers/jobAgents",
                        "timeAggregation": "Count"
                    }
                ],
                "windowSize": "PT1H",
                "windowEndTime": "2026-03-15T07:17:38.737Z",
                "windowStartTime": "2026-03-15T06:17:38.737Z",
                "staticThresholdFailingPeriods": {
                    "minFailingPeriodsToAlert": 0,
                    "numberOfEvaluationPeriods": 0
                }
            },
            "properties": null,
            "conditionType": "SingleResourceMultipleMetricCriteria"
        },
        "customProperties": null
    },
    "schemaId": "azureMonitorCommonAlertSchema"
}
"@

(Invoke-RestMethod -Uri "http://localhost:7071/api/summarize-json" -Method Post -Body $body) | ConvertTo-Json

$body = @"
{
    "tags": {
        "ip": "10.203.8.18",
        "key": "vfs.fs.size[H:,pused]",
        "host": "VMSQLTEST08",
        "value": "92.18 %",
        "trigger": "H:: Disk space is critically low (used > 90%)",
        "severity": "Average",
        "trigger_id": "34571"
    },
    "state": "PROBLEM",
    "title": "[ABCD] H:: Disk space is critically low (used > 90%) VMSQLTEST08",
    "message": "Two conditions should match: First, space utilization should be above 90.\n Second condition should be one of the following:\n - The disk free space is less than 5G.\n - The disk will be full in less than 24 hours. vfs.fs.size[H:,pused] 92.18 %",
    "alert_uid": "4518912"
}
"@
(Invoke-RestMethod -Uri "http://localhost:7071/api/summarize-json" -Method Post -Body $body) | ConvertTo-Json

$body = @"
{
    "tags": {
        "ip": "10.1.202.12",
        "host": "VMFTP01",
        "value": "Stopped (6)",
        "trigger": "FriggService (FriggService) is not running (startup type automatic delayed)",
        "severity": "Average",
        "trigger_id": "21600"
    },
    "state": "PROBLEM",
    "title": "[ABCD] FriggService (FriggService) is not running (startup type automatic delayed) VMFTP01",
    "message": "The service has a state other than Running for the last three times.",
    "alert_uid": "2201139"
}
"@
(Invoke-RestMethod -Uri "http://localhost:7071/api/summarize-json" -Method Post -Body $body) | ConvertTo-Json

$body = @"
{
    "tags": {
        "ip": "10.1.3.12",
        "host": "VM-SQL-PROD-02",
        "value": "1406.298379",
        "trigger": "The Memory Pages/sec is too high (over 1000 for 5m)",
        "severity": "Warning",
        "trigger_id": "21341"
    },
    "state": "PROBLEM",
    "title": "[ABCD] The Memory Pages/sec is too high (over 1000 for 5m) VM-SQL-PROD-02",
    "message": "The Memory Pages/sec in the last 5 minutes exceeds 1000. If the value is greater than 1,000, as a result of excessive paging, there may be a memory leak.",
    "alert_uid": "2234829"
}
"@
(Invoke-RestMethod -Uri "http://localhost:7071/api/summarize-json" -Method Post -Body $body) | ConvertTo-Json