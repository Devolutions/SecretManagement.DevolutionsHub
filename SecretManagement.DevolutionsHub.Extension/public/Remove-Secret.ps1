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
        Write-Verbose "Parsing VaultId" -Verbose:$verboseEnabled
        try {
            $vaultId = [System.Guid]::Parse($vaultId)
            Write-Verbose "$vaultId" -Verbose:$verboseEnabled
        }
        catch {
            Write-Verbose "VaultId is not a valid GUID. Looking for Vault with name: $vaultId" -Verbose:$verboseEnabled

            foreach ($hubVault in Get-HubVault) {
                if ($hubVault.Name -eq $vaultId) {
                    $vaultId = $hubVault.Id
                    $vaultFound = $true
                    break;
                }
            }

            if (-not $vaultFound) {
                throw [System.Exception] "Vault $($vauldId) not found."
            }
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
        Write-Error $_.Exception.Message
    }
    finally {
        Disconnect-DevolutionsHub($hubParameters);
    }
}
