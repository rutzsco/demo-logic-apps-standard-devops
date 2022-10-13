# Setting up the Azure DevOps Variable Groups

## Variable Group 'LogicAppDemo'

The main Azure DevOps pipelines in this project need the variable group 'LogicAppDemo', which define where your Azure resources are created.

Customize and run the following command in an Azure Cloud Shell to create this variable group:

``` bash
  az pipelines variable-group create 
    --organization=https://dev.azure.com/<yourAzDOOrg>/ 
    --project='<yourAzDOProject>' 
    --name LogicAppDemo
    --variables 
        appPrefix='<yourInitials>' 
        azureSubscription='<yourSubscriptionName/serviceConnectionName>' 
        region='eastus' 
        longAppName='logic-std-demo'
        shortAppName='logstddemo'
        keyVaultOwnerUserId='<userSID>'
```

---

## Variable Group 'LogicAppRefresh'

The Refresh Workflow pipeline in this project needs the variable group 'LogicAppRefresh' to know where the design environment is located and how it's linked to the Git Repo to be updated.

Notes:

- The tenantId/principalId/clientSecret set must be from a service principal with rights to read the logic app found in resourceGroupName/logicAppName.

- The GITHUB_TOKEN is a PAT token that had rights to update the repository and create a pull request with the changes, once the design has been updated updated and the user triggers the refresh workflow.

Customize and run the following command in an Azure Cloud Shell to create this variable group:

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

---

## Additional Setup Commands

These commands *may* be needed when you begin to run the create variable group commands:

``` bash
  az login
  az devops configure --defaults organization=https://dev.azure.com/<yourAzDOOrg>/ 
  az devops configure --defaults project='<yourAzDOProject>' 
```
