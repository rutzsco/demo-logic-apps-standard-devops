// --------------------------------------------------------------------------------
// This BICEP file will create KeyVault secret for a storage account connection
// --------------------------------------------------------------------------------
param keyVaultName string = ''
param keyName string = ''
param storageAccountName string = ''
param location string = resourceGroup().location
param utcValue string = utcNow()
// @description('Specifies the ID of the user-assigned managed identity.')
// param identityId string

// --------------------------------------------------------------------------------
resource storageAccountResource 'Microsoft.Storage/storageAccounts@2021-04-01' existing = { name: storageAccountName }
var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountResource.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccountResource.id, storageAccountResource.apiVersion).keys[0].value}'

// --------------------------------------------------------------------------------
// This should work if you run the script repeatedly as part of your deploy, and it
// will ONLY adds a new secret version if the value has changed or does not exist 
//
// This script works fine locally, but fails when part of a bicep deployment:
// "code": "DeploymentScriptError",
// "message": "The provided script failed with the following error:\r\nSystem.Management.Automation.CommandNotFoundException: 
//    The term 'Get-AzureKeyVaultSecret' is not recognized as the name of a cmdlet, function, script file, or operable program.
//    Check the spelling of the name, or if a path was included, verify that the path is correct and try again.\n   at System.Management.Automation.ExceptionHandlingOps.CheckActionPreference(FunctionContext funcContext, Exception exception)\n   at System.Management.Automation.Interpreter.ActionCallInstruction`2.Run(InterpretedFrame frame)\n   at System.Management.Automation.Interpreter.EnterTryCatchFinallyInstruction.Run(InterpretedFrame frame)\n   at System.Management.Automation.Interpreter.EnterTryCatchFinallyInstruction.Run(InterpretedFrame frame)\n   at System.Management.Automation.Interpreter.Interpreter.Run(InterpretedFrame frame)\n   at System.Management.Automation.Interpreter.LightLambda.RunVoid1[T0](T0 arg0)\n   at System.Management.Automation.ScriptBlock.InvokeWithPipeImpl(ScriptBlockClauseToInvoke clauseToInvoke, Boolean createLocalScope, Dictionary`2 functionsToDefine, List`1 variablesToDefine, ErrorHandlingBehavior errorHandlingBehavior, Object dollarUnder, Object input, Object scriptThis, Pipe outputPipe, InvocationInfo invocationInfo, Object[] args)\n   at System.Management.Automation.ScriptBlock.InvokeWithPipeImpl(Boolean createLocalScope, Dictionary`2 functionsToDefine, List`1 variablesToDefine, ErrorHandlingBehavior errorHandlingBehavior, Object dollarUnder, Object input, Object scriptThis, Pipe outputPipe, InvocationInfo invocationInfo, Object[] args)\n   at System.Management.Automation.ScriptBlock.InvokeWithPipe(Boolean useLocalScope, ErrorHandlingBehavior errorHandlingBehavior, Object dollarUnder, Object input, Object scriptThis, Pipe outputPipe, InvocationInfo invocationInfo, Boolean propagateAllExceptionsToTop, List`1 variablesToDefine, Dictionary`2 functionsToDefine, Object[] args)\n   at System.Management.Automation.ScriptBlock.InvokeUsingCmdlet(Cmdlet contextCmdlet, Boolean useLocalScope, ErrorHandlingBehavior errorHandlingBehavior, Object dollarUnder, Object input, Object scriptThis, Object[] args)\n   at Microsoft.PowerShell.Commands.InvokeExpressionCommand.ProcessRecord()\n   at System.Management.Automation.Cmdlet.DoProcessRecord()\n   at System.Management.Automation.CommandProcessor.ProcessRecord()\r\nat <ScriptBlock>, /mnt/azscripts/azscriptinput/userscript.ps1: line 4\r\nat <ScriptBlock>, <No file>: line 1\r\nat <ScriptBlock>, /mnt/azscripts/azscriptinput/DeploymentScript.ps1: line 295. Please refer to https://aka.ms/DeploymentScriptsTroubleshoot for more deployment script information."
//
// See: https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deployment-script-template?tabs=CLI#debug-deployment-scripts
// --------------------------------------------------------------------------------
resource addSecretIfNotExists 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'addSecretIfNotExists'
  location: location
  // identity: {
  //   type: 'UserAssigned'
  //   userAssignedIdentities: {
  //     '${identityId}': {
  //     }
  //   }
  // }
  kind: 'AzurePowerShell'
  properties: {
    forceUpdateTag: utcValue
    azPowerShellVersion: '6.4'
    timeout: 'PT30M'
    arguments: ' -KeyVaultName ${keyVaultName} -SecretName ${keyName} -SecretValue ${storageAccountConnectionString}'
    scriptContent: 'Param ([string] $KeyVaultName, [string] $SecretName, [string] $SecretValue)\n az login \n Install-Module Az.KeyVault -Scope CurrentUser -Force \n Write-Output "  Searching $($KeyVaultName) for Secret $($SecretName)"\n $secretObject = Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName\n $currentValue = ""\n if ($secretObject) {\n     $currentValue = $secretObject.secretvalue | ConvertFrom-SecureString -AsPlainText\n }\n $secureValue = ConvertTo-SecureString -String $SecretValue -AsPlainText -Force\n if ($currentValue) {\n     Write-Output "      Found Existing Value!";\n     if ($currentValue.IndexOf($SecretValue) -eq 0 -and ($SecretValue.Length) -eq $currentValue.Length) {\n         Write-Output "        Value is already the proper value!";\n     }\n     else {\n         Write-Output "        Disabling Old Key Vault Value!"\n         Update-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -Enable $False\n         Write-Output "        Adding New Version of Key Vault Secret!"\n         Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $secureValue\n     }\n }\n else {\n     Write-Output "        Adding New Key Vault Secret!"\n     Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $secureValue \n }'
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

