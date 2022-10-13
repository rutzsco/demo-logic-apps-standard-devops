# To deploy this main.bicep manually:
# az login
# az account set --subscription <subscriptionId>
az deployment group create -n main-deploy-20221013T153000Z --resource-group rg_logappstd_demo --template-file 'main.bicep' --parameters appPrefix=lll environment=demo longAppName=logic-app-std shortAppName=logappstd keyVaultOwnerUserId=xxxxx