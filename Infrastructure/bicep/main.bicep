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

// --------------------------------------------------------------------------------
module blobStorageAccountModule 'storageaccount.bicep' = {
  name: 'storage${deploymentSuffix}'
  params: {
    storageSku: 'Standard_LRS'

    lowerAppPrefix: lowerAppPrefix
    longAppName: longAppName
    shortAppName: shortAppName
    environment: environment
    location: location
    runDateTime: runDateTime
  }
}

module logAnalyticsModule 'log-analytics.bicep' = {
  name: 'logAnalytics${deploymentSuffix}' 
  params: {
    lowerAppPrefix: lowerAppPrefix
    longAppName: longAppName
    environment: environment
    location: location
    runDateTime: runDateTime
  }
}

module logicAppServiceModule 'logic-app-service.bicep' = {
  name: 'logicappservice${deploymentSuffix}'
  params: {
    logwsid: logAnalyticsModule.outputs.id
    blobStorageConnectionRuntimeUrl: blobStorageAccountModule.outputs.connectionRuntimeUrl
    blobStorageConnectionName: blobStorageAccountModule.outputs.blobStorageConnectionName
    blobStorageAccountName: blobStorageAccountModule.outputs.name

    lowerAppPrefix: lowerAppPrefix
    longAppName: longAppName
    shortAppName: shortAppName
    environment: environment
    location: location
    runDateTime: runDateTime
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
    enabledForDeployment: true
    //objectId: logicAppServiceModule.outputs.managedIdentityPrincipalId
    adminUserObjectIds: [ keyVaultOwnerUserId ]
    applicationUserObjectIds: [ logicAppServiceModule.outputs.managedIdentityPrincipalId ]
    
    lowerAppPrefix: lowerAppPrefix
    longAppName: longAppName
    shortAppName: shortAppName
    environment: environment
    location: location
    runDateTime: runDateTime
  }
}

// resource keyVaultResource 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = { 
//   name: keyVaultModule.outputs.name
// }

module keyVaultSecret1 'key-vault-secret-storageconnection.bicep' = {
  name: 'keyVaultSecret1${deploymentSuffix}'
  dependsOn: [ keyVaultModule, blobStorageAccountModule ]
  params: {
    keyVaultName: keyVaultModule.outputs.name
    keyName: 'BlobStorageConnectionString'
    storageAccountName: blobStorageAccountModule.outputs.name
//    previousValue: keyVaultResource.getSecret('BlobStorageConnectionString')
  }
}
