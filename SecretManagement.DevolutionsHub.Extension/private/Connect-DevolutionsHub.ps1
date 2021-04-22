using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Hub.PowerShell

function Connect-DevolutionsHub {
    [CmdletBinding()]
    param(
        $hubParameters
    )
    
    # Check vault ID
    if (-not $hubParameters.VaultId) {
        throw "VaultId not found! Please configure a Hub VaultId to your SecretVault."
    }

    # Only checks if VaultId is a GUID
    Write-Verbose "Parsing VaultId" -Verbose:$verboseEnabled
    try {
        $vaultId = [System.Guid]::Parse($hubParameters.VaultId)
        Write-Verbose "$vaultId" -Verbose:$verboseEnabled
    }
    catch {
        Write-Verbose "VauldId is not a valid ID." -Verbose:$verboseEnabled
    }

    $PSHubContext = [Devolutions.Hub.PowerShell.Entities.PowerShell.PSHubContext] @{
        ApplicationKey    = $hubParameters.ApplicationKey; 
        ApplicationSecret = $hubParameters.ApplicationSecret; 
        Url               = $hubParameters.Url
    }

    Write-Verbose 'Connecting to Hub' -Verbose:$verboseEnabled
    Connect-HubAccount -PSHubContext $PSHubContext;
    Write-Verbose 'Connected to Hub' -Verbose:$verboseEnabled
}