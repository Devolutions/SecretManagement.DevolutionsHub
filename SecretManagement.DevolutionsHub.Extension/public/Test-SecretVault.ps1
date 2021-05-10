
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

        Connect-DevolutionsHub($VaultName, $hubParameters)
        return $true
    }
    catch {
        Write-Error $_.Exception.Message
        return $false
    }
    finally {
        Disconnect-DevolutionsHub($hubParameters)
    }
    
}
