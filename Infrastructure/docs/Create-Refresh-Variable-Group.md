# Set up a Azure DevOps Variable Groups

The Azure DevOps Refresh Workflow pipeline in this project needs this variable group.

To create it, customize and run the following commands in an Azure Cloud Shell.

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
        resourceGroupName="rg_logappstd_demo"
        logicAppName="lll-logic-app-std-demo"
```
