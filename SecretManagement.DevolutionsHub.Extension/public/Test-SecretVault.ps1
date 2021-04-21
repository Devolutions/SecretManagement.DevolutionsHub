
function Test-SecretVault {
    [CmdletBinding()]
    param (
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
    Write-Verbose "Test-SecretVault: $VaultName" -Verbose:$verboseEnabled

    $hubParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    try {
        if (-not $hubParameters.VaultId) {
            throw "Vault Id isn't set."
        }

        Connect-DevolutionsHub($VaultName, $hubParameters) # Connect-HubAccount returning the context would be useful
        $hubContext = Get-HubContext | Where-Object {$_.ApplicationKey -eq $hubParameters.ApplicationKey} | Select-Object -First 1
        return -not ($null -eq $hubContext)
    }
    catch {
        Write-Verbose $_.Exception.Message -Verbose:$verboseEnabled
    }
    finally {
        Disconnect-DevolutionsHub($hubParameters)
    }
    
}
