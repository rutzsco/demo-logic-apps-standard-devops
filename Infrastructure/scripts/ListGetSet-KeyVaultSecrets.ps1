# NOTE: You may have to run Connect-AzureRmAccount to login first to run this locally
Function SetKeyVaultValue {
    Param ([string] $KeyVaultName, [string] $SecretName, [string] $SecretValue)
    Write-Output "  Searching $($KeyVaultName) for Secret $($SecretName)"
    $secretObject = Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName
    $currentValue = ""
    if ($secretObject) {
        $currentValue = $secretObject.secretvalue | ConvertFrom-SecureString -AsPlainText
    }
    $secureValue = ConvertTo-SecureString -String $SecretValue -AsPlainText -Force
    if ($currentValue) {
        Write-Output "      Found Existing Value!";
        #Write-Output "      Found Existing Value = $($currentValue)";
        if ($currentValue.IndexOf($SecretValue) -eq 0 -and ($SecretValue.Length) -eq $currentValue.Length) {
            Write-Output "        Value is already the proper value!";
        }
        else {
            Write-Output "        Disabling Old Key Vault Value!"
            Update-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -Enable $False
            Write-Output "        Adding New Version of Key Vault Secret!"
            #Write-Output "        Adding New Version of Key Vault Secret $($SecretName) = $($SecretValue)"
            Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $secureValue
        }
    }
    else {
        Write-Output "        Adding New Key Vault Secret!"
        #Write-Output "        Adding New Vault Secret $($SecretName) = $($SecretValue)"
        Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $secureValue 
    }
}

Function ListKeyVaultSecrets
{
  Param ([string] $KeyVaultName)
  $secretList = Get-AzureKeyVaultSecret -VaultName $KeyVaultName
  ForEach ($secret in $secretList) {
    if ($secret.Enabled) {
        $secretObject = Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $secret.Name;
        $secretValue = $secretObject.secretvalue | ConvertFrom-SecureString -AsPlainText
        Write-Output "  Secret $($secret.Name) = $($secretValue)";
    } else {
        Write-Output "  $($secret.Name) = KEY IS DISABLED!  (Version=NONE)";
    }
  }
} 

Function GetKeyVaultSecret
{
  Param ([string] $KeyVaultName, [string] $SecretName)
  $secret = Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName
  if ($secret.Enabled) {
    $secretObject = Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $secret.Name;
    $secretValue = $secretObject.secretvalue | ConvertFrom-SecureString -AsPlainText
    Write-Output "  Secret $($secret.Name) = $($secretValue)";
  } else {
    Write-Output "  $($secret.Name) = KEY IS DISABLED!  (Version=NONE)";
  }
} 

SetKeyVaultValue -KeyVaultName llllogappstdvaultdemo -SecretName test -SecretValue secret
ListKeyVaultSecrets -KeyVaultName llllogappstdvaultdemo
GetKeyVaultSecret -KeyVaultName llllogappstdvaultdemo -SecretName test
