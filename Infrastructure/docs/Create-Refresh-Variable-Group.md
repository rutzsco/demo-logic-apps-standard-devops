# Set up a Azure DevOps Variable Groups

The Azure DevOps Refresh Workflow pipeline in this project needs this variable group.

The tenantId/principalId/clientSecret must be for a service principal with rights to read the logic app found in resourceGroupName/logicAppName. Once the code is updated, the GITHUB_TOKEN is a PAT token that had rights to update the repository and create a pull request with the changes.

To create this group, customize and run the following commands in an Azure Cloud Shell.

These commands *may* be needed when you begin:

``` bash
  az login
  az devops configure --defaults organization=https://dev.azure.com/<yourAzDOOrg>/ 
  az devops configure --defaults project='<yourAzDOProject>' 
```

These commands actually create the variable groups:

``` bash
  az pipelines variable-group create 
    --organization=https://dev.azure.com/<yourAzDOOrg>/ 
    --project='<yourAzDOProject>' 
    --name LogicAppRefresh
    --variables 
        tenantId='<yourTenantId>'
        principalId='<yourPrincipalId>'
        clientSecret='<yourClientSecret>'
        resourceGroupName="<yourResourceGroupName>"
        logicAppName="<yourLogicAppName>"
        GITHUB_TOKEN="<GH Personal Access Token>"
```
