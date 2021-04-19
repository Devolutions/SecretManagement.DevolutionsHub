
function Test-SecretVault {
    [CmdletBinding()]
    param (
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
    Write-Verbose "Test-SecretVault: $VaultName" -Verbose:$verboseEnabled

    try {
        # should be changed to use private function
        $hubParameters = (Get-SecretVault -Name $VaultName).VaultParameters

        $url = $hubParameters.Url;
        $applicationSecret = $hubParameters.ApplicationSecret;
        $applicationKey = $hubParameters.ApplicationKey;

        #this should not be necessary
        if (-not $url) {
            $url = Read-Host 'Url: ';
        }

        if (-not $applicationKey) {
            $applicationKey = Read-Host 'Application Key: ';
        }

        if (-not $applicationSecret) {
            $applicationSecret = Read-Host 'Application Secret: ';
        }

        Connect-HubAccount -Url $url -ApplicationSecret $applicationSecret -ApplicationKey $applicationKey
        # Connect-HubAccount returning the context would be useful
        $hubContext = Get-HubContext;

        return -not ($null -eq $hubContext) # cant know if this is the right one
    }
    catch {
        
    }
    
}
