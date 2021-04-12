using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Hub.PowerShell

function Connect-DevolutionsHub {
    [CmdletBinding()]
    param(
        [Alias('Name')][string]$Filter, # not used
        [string]$VaultName = (Get-SecretVault).VaultName,
        [hashtable]$AdditionalParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    )

    $PSHubContext = [Devolutions.Hub.PowerShell.Entities.PowerShell.PSHubContext] @{
        ApplicationKey=$AdditionalParameters.ApplicationKey; 
        ApplicationSecret=$AdditionalParameters.ApplicationSecret; 
        Url=$AdditionalParameters.Url
    }

    Connect-HubAccount -PSHubContext $PSHubContext;
}