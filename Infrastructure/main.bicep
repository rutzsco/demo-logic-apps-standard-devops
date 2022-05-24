param location string = 'eastus'

param logicAppServiceName string = 'rutzsco-demo-logic-app'
param storageAccountName string = 'rutzscodemologicapp'
param logAnalyticsWorkspaceName string = 'rutzsco-demo-logic-app'

// Service Bus
module logAnalytics 'log-analytics.bicep' = {
  name: 'logAnalytics' 
  params: {
    location: location
    name: logAnalyticsWorkspaceName
  }
}

// Service Bus
module sb 'logic-app-service.bicep' = {
  name: 'sb'
  params: {
    location: location
    name: logicAppServiceName
    storageAccountName: storageAccountName
     logwsid: logAnalytics.outputs.id
  }
}
