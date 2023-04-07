### Assign roles to Azure AD groups in subscription

1. Make a deployment, when managed identity exists, go to step 2.
2. Run powershell script `managedIdentity.ps1` manually to assign Azure AD role `Groups Administrator`.
3. Make a deployment again to create Azure AD groups with Deployment script.
4. Copy ObjectId in bicep template.