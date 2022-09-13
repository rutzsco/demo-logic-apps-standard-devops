# Set up an Azure DevOps Variable Groups

## Note: These Azure DevOps pipelines need these variable groups: "LogicAppDemo*"

To create these variable groups, customize and run this command in the Azure Cloud Shell:

```
  az login
  az devops configure --defaults organization=https://dev.azure.com/<yourAzDOOrg>/ 
  az devops configure --defaults project='<yourAzDOProject>' 

  az pipelines variable-group create 
    --organization=https://dev.azure.com/<yourAzDOOrg>/ 
    --project='<yourAzDOProject>' 
    --name LogicAppDemo
    --variables 
        appPrefix='<yourInitials>' 
        azureSubscription='<yourSubscriptionName/serviceConnectionName>' 
        azureSubscriptionId='<yourSubscriptionId>' 
        blobStorageContributorId='<yourServicePrincipalId>' 
        region='eastus' 
        resourceGroupNameDev='rg-logic-app-demo-dev' 
        resourceGroupNameQA='rg-logic-app-demo-qa' 
        virtualNetworkName='<yourInitials>-demo-logic-app-vnet' 

  az pipelines variable-group create 
    --organization=https://dev.azure.com/<yourAzDOOrg>/ 
    --project='<yourAzDOProject>' 
    --name LogicAppDemoDev
    --variables 
        logicAppNameDev='<yourInitials>-demo-logic-app-dev' 
        storageAccountNameDev='<yourInitials>demolablobsdev' 

  az pipelines variable-group create 
    --organization=https://dev.azure.com/<yourAzDOOrg>/ 
    --project='<yourAzDOProject>' 
    --name LogicAppDemoQA
    --variables 
        logicAppNameQA='<yourInitials>-demo-logic-app-qa' 
        storageAccountNameQA='<yourInitials>demolablobsqa' 
```
