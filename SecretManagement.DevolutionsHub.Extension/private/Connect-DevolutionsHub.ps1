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

    Connect-HubAccount -PSHubContext $PSHubContext;
}