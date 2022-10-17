// --------------------------------------------------------------------------------
// This BICEP file will create KeyVault secret for a storage account connection
// --------------------------------------------------------------------------------
param keyVaultName string = ''
param keyName string = ''
param storageAccountName string = ''

// --------------------------------------------------------------------------------
resource storageAccountResource 'Microsoft.Storage/storageAccounts@2021-04-01' existing = { name: storageAccountName }
var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountResource.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountResource.id, storageAccountResource.apiVersion).keys[0].value}'

// --------------------------------------------------------------------------------
// This works great once, but if you run the script repeatedly as part of your  
// deploy, it will add a new secret version each time the script runs 
// and all of them will be enabled
// --------------------------------------------------------------------------------
resource keyvaultResource 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
  resource storageSecret 'secrets' = {
    name: keyName
    properties: {
      value: storageAccountConnectionString
    }
  }
}
