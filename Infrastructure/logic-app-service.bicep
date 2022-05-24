param name string
param storageAccountName string
param environment string = 'ci'
param logwsid string
param minimumElasticSize int = 1
param location string = resourceGroup().location


// Storage account for the service
resource storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
name: '${storageAccountName}${environment}'
location: location
kind: 'StorageV2'
sku: {
  name: 'Standard_GRS'
}
properties: {
  supportsHttpsTrafficOnly: true
  minimumTlsVersion: 'TLS1_2'
}
}

// Dedicated app plan for the service
resource plan 'Microsoft.Web/serverfarms@2021-02-01' = {
name: 'plan-${name}-logic-${environment}'
location: location
sku: {
  tier: 'WorkflowStandard'
  name: 'WS1'
}
properties: {
  targetWorkerCount: minimumElasticSize
  maximumElasticWorkerCount: 20
  elasticScaleEnabled: true
  isSpot: false
  zoneRedundant: true
}
}

// Create application insights
resource appi 'Microsoft.Insights/components@2020-02-02' = {
name: 'appi-${name}-logic-${environment}'
location: location
kind: 'web'
properties: {
  Application_Type: 'web'
  Flow_Type: 'Bluefield'
  publicNetworkAccessForIngestion: 'Enabled'
  publicNetworkAccessForQuery: 'Enabled'
  Request_Source: 'rest'
  RetentionInDays: 30
  WorkspaceResourceId: logwsid
}
}

// App service containing the workflow runtime
resource site 'Microsoft.Web/sites@2021-02-01' = {
name: 'logic-${name}-${environment}'
location: location
kind: 'functionapp,workflowapp'
identity: {
  type: 'SystemAssigned'
}
properties: {
  httpsOnly: true
  siteConfig: {
    appSettings: [
      {
        name: 'FUNCTIONS_EXTENSION_VERSION'
        value: '~3'
      }
      {
        name: 'FUNCTIONS_WORKER_RUNTIME'
        value: 'node'
      }
      {
        name: 'WEBSITE_NODE_DEFAULT_VERSION'
        value: '~12'
      }
      {
        name: 'AzureWebJobsStorage'
        value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${listKeys(storage.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
      }
      {
        name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
        value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};AccountKey=${listKeys(storage.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
      }
      {
        name: 'WEBSITE_CONTENTSHARE'
        value: 'app-${toLower(name)}-logicservice-${toLower(environment)}a6e9'
      }
      {
        name: 'AzureFunctionsJobHost__extensionBundle__id'
        value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
      }
      {
        name: 'AzureFunctionsJobHost__extensionBundle__version'
        value: '[1.*, 2.0.0)'
      }
      {
        name: 'APP_KIND'
        value: 'workflowApp'
      }
      {
        name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
        value: appi.properties.InstrumentationKey
      }
      {
        name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
        value: '~2'
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: appi.properties.ConnectionString
      }
    ]
    use32BitWorkerProcess: true
  }
  serverFarmId: plan.id
  clientAffinityEnabled: false
}
}

// Return the Logic App service name and farm name
output app string = site.name
output plan string = plan.name
