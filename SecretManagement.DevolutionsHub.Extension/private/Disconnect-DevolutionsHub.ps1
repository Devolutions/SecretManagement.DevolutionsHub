using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Hub.PowerShell

function Disconnect-DevolutionsHub {
    [CmdletBinding()]
    param(
        $hubParameters
    )
    
    $hubContext = Get-HubContext | Where-Object {$_.ApplicationKey -eq $hubParameters.ApplicationKey} | Select-Object -First 1
    if ($null -eq $hubContext)
    {
        Write-Verbose 'Not connected' -Verbose:$verboseEnabled
        return
    }

    Disconnect-HubAccount -ApplicationKey $hubParameters.ApplicationKey;
    Write-Verbose 'Disconnected' -Verbose:$verboseEnabled
}
