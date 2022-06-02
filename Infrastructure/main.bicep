param location string = 'eastus'
param roleDefinitionId string = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' //Default as Storage Blob Data Contributor role

param logicAppServiceName string = 'rutzsco-demo-logic-app'
param storageAccountName string = 'rutzscodemologicapp'
param logAnalyticsWorkspaceName string = 'rutzsco-demo-logic-app'



// Log Analytics
module logAnalytics 'log-analytics.bicep' = {
  name: 'logAnalytics' 
  params: {
    location: location
    name: logAnalyticsWorkspaceName
  }
}

var blobStorageConnectionName = '${storageAccountName}-blobconnection'
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
// Logic Apps Service
module la 'logic-app-service.bicep' = {
  name: 'la'
  params: {
    location: location
    name: logicAppServiceName
    storageAccountName: storageAccountName
    logwsid: logAnalytics.outputs.id
    blobStorageConnectionRuntimeUrl: connectionRuntimeUrl
  }
}

// Connections SA
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
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

resource logicAppStorageAccountRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: storageAccount
  name: guid('ra-logicapp-${roleDefinitionId}')
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: la.outputs.managedIdentityPrincipalId
  }
}
