# Set up an Azure DevOps Variable Groups

## Note: The Azure DevOps pipelines need these three variable groups:

To create these variable groups, customize and run these commands in an Azure Cloud Shell:

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
        region='eastus' 

  az pipelines variable-group create 
    --organization=https://dev.azure.com/<yourAzDOOrg>/ 
    --project='<yourAzDOProject>' 
    --name LogicAppDemo-Dev
    --variables 
        blobStorageContributorId='<yourServicePrincipalId>' 
        logicAppNameDev='<yourInitials>-demo-logic-app-dev' 
        resourceGroupName='rg_logic_demo_dev' 
        storageAccountNameDev='<yourInitials>demolablobsdev' 
        virtualNetworkName='<yourInitials>-demo-logic-app-vnet' 

  az pipelines variable-group create 
    --organization=https://dev.azure.com/<yourAzDOOrg>/ 
    --project='<yourAzDOProject>' 
    --name LogicAppDemo-QA
    --variables 
        blobStorageContributorId='<yourServicePrincipalId>' 
        logicAppNameQA='<yourInitials>-demo-logic-app-qa' 
        resourceGroupName='rg_logic_demo_qa' 
        storageAccountName='<yourInitials>demolablobsqa' 
        virtualNetworkName='<yourInitials>-demo-logic-app-vnet' 
```
