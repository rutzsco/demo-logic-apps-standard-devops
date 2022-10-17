// --------------------------------------------------------------------------------
// Logic Apps Standard - Main Bicep File
// --------------------------------------------------------------------------------
param appPrefix string = 'myorgname'
@allowed(['demo','design','dev','qa','stg','prod'])
param environment string = 'demo'
param location string = 'eastus'
param blobStorageContributorId string = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
param longAppName string = 'logic-std-demo'
param shortAppName string = 'logstddemo'
param keyVaultOwnerUserId string = ''
param runDateTime string = utcNow()

// --------------------------------------------------------------------------------
var deploymentSuffix = '-${runDateTime}'
var lowerAppPrefix = toLower(appPrefix)
var commonTags = {         
  LastDeployed: runDateTime
  AppPrefix: lowerAppPrefix
  AppName: longAppName
  Environment: environment
}

// --------------------------------------------------------------------------------
module resourceNames 'resource-names.bicep' = {
  name: 'resourcenames${deploymentSuffix}'
  params: {
    lowerAppPrefix: lowerAppPrefix
    longAppName: longAppName
    shortAppName: shortAppName
    environment: environment
  }
}

// --------------------------------------------------------------------------------
module blobStorageAccountModule 'storageaccount.bicep' = {
  name: 'storage${deploymentSuffix}'
  params: {
    storageAccountName: resourceNames.outputs.storageAccountName
    blobStorageConnectionName: resourceNames.outputs.blobStorageConnectionName
    storageSku: 'Standard_LRS'
    location: location
    commonTags: commonTags
  }
}

module logAnalyticsModule 'log-analytics.bicep' = {
  name: 'logAnalytics${deploymentSuffix}' 
  params: {
    logAnalyticsWorkspaceName: resourceNames.outputs.logAnalyticsWorkspaceName
    location: location
    commonTags: commonTags
  }
}

module logicAppServiceModule 'logic-app-service.bicep' = {
  name: 'logicappservice${deploymentSuffix}'
  params: {
    logicAppServiceName:  resourceNames.outputs.logicAppServiceName
    logicAppStorageAccountName: resourceNames.outputs.logicAppStorageAccountName
    logwsid: logAnalyticsModule.outputs.id
    environment: environment
    location: location
    commonTags: commonTags
  }
}

module storageAccountRoleModule 'storageaccountroles.bicep' = {
  name: 'storageaccountroles${deploymentSuffix}' 
  params: {
    logicAppServiceName: logicAppServiceModule.outputs.name
    storageAccountName: blobStorageAccountModule.outputs.name
    logicAppServicePrincipalId: logicAppServiceModule.outputs.managedIdentityPrincipalId
    blobStorageConnectionName: blobStorageAccountModule.outputs.blobStorageConnectionName
    blobStorageContributorId: blobStorageContributorId

    environment: environment
    location: location
  }
}

module keyVaultModule 'key-vault.bicep' = {
  name: 'keyvault${deploymentSuffix}'
  params: {
    keyVaultName: resourceNames.outputs.keyVaultName
    adminUserObjectIds: [ keyVaultOwnerUserId ]
    applicationUserObjectIds: [ logicAppServiceModule.outputs.managedIdentityPrincipalId ]
    location: location
    commonTags: commonTags
  }
}

module keyVaultSecret1 'key-vault-secret-storageconnection.bicep' = {
  name: 'keyVaultSecret1${deploymentSuffix}'
  dependsOn: [ keyVaultModule, blobStorageAccountModule ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    keyName: 'BlobStorageConnectionString'
    storageAccountName: blobStorageAccountModule.outputs.name
  }
}


module functionAppSettingsModule 'logic-app-settings.bicep' = {
  name: 'functionAppSettings${deploymentSuffix}'
  // dependsOn: [  keyVaultSecrets ]
  params: {
    logicAppName: logicAppServiceModule.outputs.name
    logicAppStorageAccountName: logicAppServiceModule.outputs.storageResourceName
    logicAppInsightsKey: logicAppServiceModule.outputs.insightsKey
    customAppSettings: {
      BLOB_CONNECTION_RUNTIMEURL: blobStorageAccountModule.outputs.connectionRuntimeUrl
      BLOB_STORAGE_CONNECTION_NAME: blobStorageAccountModule.outputs.blobStorageConnectionName
      BLOB_STORAGE_ACCOUNT_NAME: blobStorageAccountModule.outputs.name
      WORKFLOWS_SUBSCRIPTION_ID: subscription().subscriptionId
      WORKFLOWS_RESOURCE_GROUP_NAME: resourceGroup().name
      WORKFLOWS_LOCATION_NAME: location
    }
  }
}


