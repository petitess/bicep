### Add managed identity or service principal to a database
#### Add service connection in devops for managed identity or service principal to run pipeline
```tsql
CREATE USER [id-abc-dev-01] FROM EXTERNAL PROVIDER WITH OBJECT_ID='12345678-01ae-42fa-8152-db456a5aa43b';
CREATE USER [sp-sub-labb-01] FROM EXTERNAL PROVIDER WITH OBJECT_ID='12345678-4852-42b6-80ce-722eb3251706';
SELECT * FROM sysusers
```
### Add roles for an identity
```tsql
ALTER ROLE db_datareader ADD MEMBER [id-abc-dev-01];
ALTER ROLE db_datawriter ADD MEMBER [id-abc-dev-01];
ALTER ROLE db_datareader DROP MEMBER [id-abc-dev-01];
```
### Check assigned roles for an identity
```tsql
SELECT
    dp.name AS UserName,
    rp.name AS RoleName
FROM sys.database_role_members drm
JOIN sys.database_principals rp
    ON drm.role_principal_id = rp.principal_id
JOIN sys.database_principals dp
    ON drm.member_principal_id = dp.principal_id
WHERE dp.name = 'id-abc-dev-01';
```
### Create a table
```tsql
CREATE TABLE [dbo].Computer(
	ComputerId INT IDENTITY(1,1) PRIMARY KEY,
	Motherboard NVARCHAR(50),
	CPUCores INT,
	HasWifi BIT,
	HasLTE BIT,
	ReleaseDate DATE,
	Price DECIMAL(18,4),
	VideoCard NVARCHAR(50)
);
CREATE TABLE [dbo].WeatherInfo(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	City NVARCHAR(50),
	Temperature INT,
	Description NVARCHAR(50)
);
```
### Start a job in Elastic Job agent
```powershell
$Token = az account get-access-token --query accessToken --output tsv
$headers = @{
    "Authorization" = "Bearer $Token"
    "Content-type" = "application/json"
}
$Url = "https://management.azure.com/subscriptions/xyz/resourceGroups/rg-sql-czr-dev-01/providers/Microsoft.Sql/servers/sql-system-infra-dev-01/jobAgents/sqlja-elastic-job/jobs/JobSelection/start?api-version=2025-01-01"
Invoke-RestMethod -Method POST -URI $URL -Headers $headers
```
