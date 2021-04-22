# SecretManagement.DevolutionsHub

## Quick Start

* Setup Devolutions Hub Vault

* Install SecretManagement.DevolutionsHub 
```Powershell
Install-Module SecretManagement.DevolutionsHub
```

* Register Vault
```PowerShell
Register-SecretVault -Name 'hubVaultName' -ModuleName 'SecretManagement.DevolutionsHub' -VaultParameters @{
    Url = ""
    ApplicationKey = ""
    ApplicationSecret = ""
    VaultId = ""
}
```

* Test the vault
```PowerShell
Test-SecretVault -Vault 'hubVaultName'
```

* Add an entry to the stored vault
```PowerShell
Set-Secret -VaultName 'hubVaultName' -Name 'entryName' -Secret $credentials
```

* Get a list of available entries from the stored vault
```PowerShell
Get-SecretInfo -VaultName 'hubVaultName'
```

* Get an entry using the stored vault. Providing an ID in the name field will be much faster than the entry's name
```PowerShell
Get-Secret -VaultName 'hubVaultName' -Name 'entryName'
```

* Remove an entry from the stored vault
```PowerShell
Remove-Secret -VaultName 'hubVaultName'
```