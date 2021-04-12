using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Hub.PowerShell

function Disconnect-DevolutionsHub {
    [CmdletBinding()]
    param(
        [Alias('Name')][string]$Filter, # not used
        [string]$VaultName = (Get-SecretVault).VaultName,
        [hashtable]$AdditionalParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    )
    
    Disconnect-HubAccount -ApplicationKey $AdditionalParameters.ApplicationKey;
}