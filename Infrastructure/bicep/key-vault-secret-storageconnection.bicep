// --------------------------------------------------------------------------------
// This BICEP file will create KeyVault secret for a storage account connection
// --------------------------------------------------------------------------------
param keyVaultName string = ''
param keyName string = ''
param storageAccountName string = ''
param location string = resourceGroup().location
param utcValue string = utcNow()

// --------------------------------------------------------------------------------
resource storageAccountResource 'Microsoft.Storage/storageAccounts@2021-04-01' existing = { name: storageAccountName }
var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountResource.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountResource.id, storageAccountResource.apiVersion).keys[0].value}'

// --------------------------------------------------------------------------------
// This should work if you run the script repeatedly as part of your deploy, and it
// will ONLY adds a new secret version if the value has changed or does not exist 
// --------------------------------------------------------------------------------
resource addSecretIfNotExists 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'addSecretIfNotExists'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    forceUpdateTag: utcValue
    azPowerShellVersion: '6.4'
    timeout: 'PT30M'
    arguments: ' -KeyVaultName ${keyVaultName} -SecretName ${keyName} -SecretValue ${storageAccountConnectionString}'
    scriptContent: 'Param ([string] $KeyVaultName, [string] $SecretName, [string] $SecretValue)\n Write-Output "  Searching $($KeyVaultName) for Secret $($SecretName)"\n $secretObject = Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName\n $currentValue = ""\n if ($secretObject) {\n     $currentValue = $secretObject.secretvalue | ConvertFrom-SecureString -AsPlainText\n }\n $secureValue = ConvertTo-SecureString -String $SecretValue -AsPlainText -Force\n if ($currentValue) {\n     Write-Output "      Found Existing Value!";\n     if ($currentValue.IndexOf($SecretValue) -eq 0 -and ($SecretValue.Length) -eq $currentValue.Length) {\n         Write-Output "        Value is already the proper value!";\n     }\n     else {\n         Write-Output "        Disabling Old Key Vault Value!"\n         Update-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -Enable $False\n         Write-Output "        Adding New Version of Key Vault Secret!"\n         Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $secureValue\n     }\n }\n else {\n     Write-Output "        Adding New Key Vault Secret!"\n     Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $secureValue \n }'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

// // --------------------------------------------------------------------------------
// // This works great once, but if you run the script repeatedly as part of your  
// // deploy, it will add a new secret version each time the script runs 
// // --------------------------------------------------------------------------------
// resource keyvaultResource 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
//   name: keyVaultName
//   //resource storageSecret 'secrets' = if (storageAccountConnectionString != previousValue) {
//   resource storageSecret 'secrets' = {
//     name: keyName
//     properties: {
//       value: storageAccountConnectionString
//     }
//   }
// }

