param location string = 'eastus'
param roleDefinitionId string = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' //Default as Storage Blob Data Contributor role

param logicAppServiceName string = 'rutzsco-demo-logic-app'
param logicAppStorageAccountName string = 'rutzscodemola'
param workflowStorageAccountName string = 'rutzscodemolablobs'
param environment string = 'ci'

param logAnalyticsWorkspaceName string = 'rutzsco-demo-logic-app'

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
var blobStorageConnectionName = '${workflowStorageAccountName}-blobconnection-${environment}'
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
  name: 'la'
  params: {
    location: location
    name: logicAppServiceName
    storageAccountName: logicAppStorageAccountName
    logwsid: logAnalytics.outputs.id
    blobStorageConnectionRuntimeUrl: connectionRuntimeUrl
    environment: environment
  }
}

// Logic Apps - RBAC Contributor Access to Ingrgration Storage Account
resource logicAppStorageAccountRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: storageAccount
  name: guid('${logicAppServiceName}-${roleDefinitionId}-${environment}-ra')
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
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

// Key Vault - Service
module keyVault 'key-vault.bicep' = {
  name: 'kv'
  params: {
    location: '${logicAppServiceName}-${environment}'
    keyVaultName: logicAppServiceName
    objectId: la.outputs.managedIdentityPrincipalId
    secretName: 'BlobStorageConnectionString'
    secretValue: storageAccount.listKeys().keys[0].value
  }
}
