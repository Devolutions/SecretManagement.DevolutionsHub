function Test-SecretVault
{
    param (
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
    Write-Verbose "[TestLocalScript.Extension]:Test-SecretVault successfully called for vault: $VaultName" -Verbose:$verboseEnabled

    # should be changed to use private function

    $url = $AdditionalParameters.Url;
    $applicationSecret = $AdditionalParameters.ApplicationSecret;
    $applicationKey = $AdditionalParameters.ApplicationKey;

    if (-not $url) {
        $url = Read-Host 'Url: ';
    }

    if (-not $applicationKey) {
        $applicationKey = Read-Host 'Application Key: ';
    }

    if (-not $applicationSecret) {
        $applicationSecret = Read-Host 'Application Secret: ';
    }

    $context = Connect-HubAccount -Url $url -ApplicationSecret $applicationSecret -ApplicationKey $applicationKey

    return -not ($null -eq $context) # cant know if this is the right one
}