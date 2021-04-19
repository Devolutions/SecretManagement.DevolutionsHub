using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Hub.PowerShell

function Connect-DevolutionsHub {
    [CmdletBinding()]
    param(
        $hubParameters
    )
    
    $PSHubContext = [Devolutions.Hub.PowerShell.Entities.PowerShell.PSHubContext] @{
        ApplicationKey=$hubParameters.ApplicationKey; 
        ApplicationSecret=$hubParameters.ApplicationSecret; 
        Url=$hubParameters.Url
    }

    Write-Verbose 'Connecting to Hub' -Verbose:$verboseEnabled #
    Connect-HubAccount -PSHubContext $PSHubContext;
    Write-Verbose 'Connected to Hub' -Verbose:$verboseEnabled #
}