param name string
param location string = resourceGroup().location

// Create log analytics workspace
resource logws 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'PerGB2018' // Standard
    }
  }
}

// Return the workspace identifier
output id string = logws.id
