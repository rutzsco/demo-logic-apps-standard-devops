param appPrefix string = 'myorgname'
param environment string = 'DEV'
param location string = 'eastus'
// Storage Blob Data Contributor role
param blobStorageContributorId string = ''
param longAppName string = 'demo-logic-app'
param shortAppName string = 'demola'

var lowerAppPrefix = toLower(appPrefix)

var logicAppServiceName = '${lowerAppPrefix}-${longAppName}'
var logAnalyticsWorkspaceName = '${lowerAppPrefix}-${longAppName}'
var logicAppStorageAccountName = '${lowerAppPrefix}${shortAppName}app'
var workflowStorageAccountName = '${lowerAppPrefix}${shortAppName}blob'
var keyVaultName = '${lowerAppPrefix}${shortAppName}vault'

// Integration - Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: '${workflowStorageAccountName}${environment}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// Integration - Storage Account Container
resource storageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storageAccount.name}/default/myblobs'
  properties: {}
}

// Log Analytics
module logAnalytics 'log-analytics.bicep' = {
  name: 'logAnalytics' 
  params: {
    location: location
    name: '${logAnalyticsWorkspaceName}-${environment}'
  }
}

// Logic Apps - StorageConnection
var blobStorageConnectionName = '${workflowStorageAccountName}${environment}-blobconnection'
resource blobStorageConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: blobStorageConnectionName
  kind: 'V2'
  location: location
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
var connectionRuntimeUrl = reference(blobStorageConnection.id, blobStorageConnection.apiVersion, 'full').properties.connectionRuntimeUrl

// Logic Apps - Service
module la 'logic-app-service.bicep' = {
  name: 'logicappservice'
  params: {
    location: location
    name: logicAppServiceName
    storageAccountName: logicAppStorageAccountName
    logwsid: logAnalytics.outputs.id
    blobStorageConnectionRuntimeUrl: connectionRuntimeUrl
    blobStorageConnectionName: blobStorageConnectionName
    environment: environment
  }
}

// Logic Apps - RBAC Contributor Access to Ingrgration Storage Account
resource logicAppStorageAccountRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: storageAccount
  name: guid('${logicAppServiceName}-${blobStorageContributorId}-${environment}-ra')
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', blobStorageContributorId)
    principalId: la.outputs.managedIdentityPrincipalId
  }
}

// Logic Apps - Storage Connection Access Policy
resource connectionAccessPolicy 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: '${blobStorageConnection.name}/${la.name}'
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        tenantId: subscription().tenantId
        objectId: la.outputs.managedIdentityPrincipalId
      }
    }
  }
}

// Key Vault
module keyVault 'key-vault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
    keyVaultName: '${keyVaultName}${environment}'
    objectId: la.outputs.managedIdentityPrincipalId
    secretName: 'BlobStorageConnectionString'
    secretValue: storageAccount.listKeys().keys[0].value
  }
}
