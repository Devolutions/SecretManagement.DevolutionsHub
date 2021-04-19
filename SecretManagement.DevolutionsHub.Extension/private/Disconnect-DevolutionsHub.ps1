using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Hub.PowerShell

function Disconnect-DevolutionsHub {
    [CmdletBinding()]
    param(
        $hubParameters
    )
    
    Disconnect-HubAccount -ApplicationKey $hubParameters.ApplicationKey;
}