using namespace Devolutions.Hub.PowerShell

function Remove-Secret
{
    [CmdletBinding()]
    param (
        [string] $Name,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
    Write-Verbose "Remove-Secret Vault: $VaultName" -Verbose:$verboseEnabled

    $hubParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    try {
        Connect-DevolutionsHub($VaultName, $hubParameters);

        $vaultId = $hubParameters.VaultId;        
        if (-not $vaultId) {
            $vaultId = Read-Host 'Hub Vault Id ';
        }

        Write-Verbose "Parsing entry name" -Verbose:$verboseEnabled
        $entryId
        try {
            $entryId = [System.Guid]::Parse($Name)
        }
        catch {
            $entryId = Read-Host 'Hub Entry Id '
        }

        Remove-HubEntry -VaultId $vaultId -EntryId $entryId;
    }
    catch {
        Write-Verbose $_.Exception.Message -Verbose:$verboseEnabled
    }
    finally {
        Disconnect-DevolutionsHub($hubParameters);
    }
}
