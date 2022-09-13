# Set up a Azure DevOps Variable Groups

The Azure DevOps pipelines in this project need these variable groups.

To create them, customize and run the following commands in an Azure Cloud Shell.

These commands *may* be needed when you begin:
```
  az login
  az devops configure --defaults organization=https://dev.azure.com/<yourAzDOOrg>/ 
  az devops configure --defaults project='<yourAzDOProject>' 
```

These commands actually create the variable groups:
```
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
