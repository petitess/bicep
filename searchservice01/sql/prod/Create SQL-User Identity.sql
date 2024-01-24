CREATE USER [id-standard-prod-we-01] FROM  EXTERNAL PROVIDER  WITH DEFAULT_SCHEMA=[dbo]
GO
sys.sp_addrolemember @rolename = N'db_datareader', @membername = N'id-standard-prod-we-01'
GO
sys.sp_addrolemember @rolename = N'db_datawriter', @membername = N'id-standard-prod-we-01'
GO