// --------------------------------------------------------------------------------
// Create storage account
// --------------------------------------------------------------------------------
param lowerAppPrefix string = 'myorgname'
param shortAppName string = 'demola'
param longAppName string = ''
@allowed(['demo','design','dev','qa','stg','prod'])
param environment string = 'demo'
param location string = resourceGroup().location
param runDateTime string = utcNow()

@allowed([ 'Standard_LRS', 'Standard_GRS', 'Standard_RAGRS' ])
param storageSku string = 'Standard_LRS'
param containerName string = 'myblobs'

// --------------------------------------------------------------------------------
var templateFileName = '~storageAccount.bicep'
var storageAccountName = '${lowerAppPrefix}${shortAppName}blob${environment}'
var blobStorageConnectionName = '${storageAccountName}-blobconnection'

// --------------------------------------------------------------------------------
resource storageAccountResource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: storageAccountName
    location: location
    sku: {
        name: storageSku
    }
    tags: {
        LastDeployed: runDateTime
        TemplateFile: templateFileName
        AppPrefix: lowerAppPrefix
        AppName: longAppName
        Environment: environment
    }
    kind: 'StorageV2'
    properties: {
        accessTier: 'Hot'
        allowBlobPublicAccess: true
        supportsHttpsTrafficOnly: true
        minimumTlsVersion: 'TLS1_2'
    }
}

resource storageAccountBlobContainerResource 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
    name: '${storageAccountResource.name}/default/${containerName}'
    properties: {}
}

resource blobServiceResource 'Microsoft.Storage/storageAccounts/blobServices@2019-06-01' = {
    name: '${storageAccountResource.name}/default'
    properties: {
        cors: {
            corsRules: [
            ]
        }
        deleteRetentionPolicy: {
            enabled: true
            days: 7
        }
    }
}

// --------------------------------------------------------------------------------
resource blobStorageConnectionResource 'Microsoft.Web/connections@2016-06-01' = {
    name: blobStorageConnectionName
    kind: 'V2'
    location: location
    tags: {
        LastDeployed: runDateTime
        TemplateFile: templateFileName
        AppPrefix: lowerAppPrefix
        AppName: longAppName
        Environment: environment
    }
    properties: {
        api: {
            id: 'subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/azureblob'
        }
        customParameterValues: {}
        displayName: blobStorageConnectionName
        parameterValueSet: {
            name: 'managedIdentityAuth'
            values: {}
        }
    }
}
var connectionRuntimeUrl = reference(blobStorageConnectionResource.id, blobStorageConnectionResource.apiVersion, 'full').properties.connectionRuntimeUrl

// --------------------------------------------------------------------------------
output name string = storageAccountResource.name
output id string = storageAccountResource.id
output connectionRuntimeUrl string = connectionRuntimeUrl
output blobStorageContainerName string = storageAccountBlobContainerResource.name
output blobStorageConnectionName string = blobStorageConnectionResource.name
