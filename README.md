# SecretManagement.DevolutionsHub

This module is an implementation of Powershell SecretManagement for Devolutions Hub.

**Note:** Due to the encryption model of Devolutions Hub, operations are much faster when providing the id of an entry rather than its name. The )_vault id_ and _entry id_ appear in the URL when opening an entry in Hub (eg. `https://myvault.devolutions.app/assets/<vault-id>/<entry-id>/overview`).

## Quick Start

Install SecretManagement.DevolutionsHub from PSGallery.

```powershell
Install-Module SecretManagement.DevolutionsHub
```

To use this module, create an [application user](https://helphub.devolutions.net/hub_application_users.html) and take note of the application key and application secret. The vault id appears in the URL when navigating a vault. (eg.
https://myvaut.devolutions.app/assets/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx).

Register the vault with the following command:

```powerShell
Register-SecretVault -Name 'hubVaultName' -ModuleName 'SecretManagement.DevolutionsHub' -VaultParameters @{
    Url = "https://myvault.devolutions.app"
    ApplicationKey = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx;xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    ApplicationSecret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    VaultId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

To confirm that the access to the vault works, use the following command:

```powershell
Test-SecretVault -Vault 'hubVaultName'
```

## Usage

Add an entry to the stored vault:

```powershell
Set-Secret -Vault 'hubVaultName' -Name 'entryName' -Secret $credentials
```

Get a list of available entries from the stored vault:

```powershell
Get-SecretInfo -Vault 'hubVaultName'
```

Get an entry using the stored vault. Providing an ID in the name field will be much faster than the entry's name. Only `Credential` entries are supported at the moment.

```powershell
Get-Secret -Vault 'hubVaultName' -Name 'entryID'
```

Remove an entry from the stored vault.

```powershell
Remove-Secret -Vault 'hubVaultName' -Name 'entryID'
```