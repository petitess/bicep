# Introduction 
This project is here to build common resources for Standard. However the search service creates a couple of extra steps needed to complete the setup, If this is the first time you are running the pipeline then it will continue spinning untill you have approved the private link between search service and the sql database.
To approve the private link you need to head over to the SQL Server in the common resource group. Go to Networking -> Private Access -> Approve the pending "pl-standards-standard-srch-..." private link

We also need to manually add the datasource, indexer and indexes to the search service. Since this is not supported in bicep yet.
Here is a step by step guide on how to do that:
1. Head over to the Search service resource in the common resource group. Goto Data sources -> Add data source -> Data Source Defnintion (JSON) and then paste the json inside search/datasource.json in this repository into that text field. You need to change the values of the connection string to be correct. Such as {{ServerName}} to standardutv etc.
2. Go to Indexers -> Add indexer -> Indexer Definition (JSON) and then paste the json text inside of search/indexer.json in this repository into that text field.
3. Go to Indexes -> Add index (JSON) and add the json inside of search/searchindex.json into the text field.

We are using username and password to login to database here since we werent able to setup managed identities with a framework 4.7 project. So once the sql database is created you'll have to go to azure portal and set a username and password manually after the sql database is created through the pipeline.

This should be all the setup needed to get search service to work.