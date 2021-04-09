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
}
```

* Get entries using the stored vault
```
Get-Secret -Name 'entry1' -VaultName 'hubVaultName'
```