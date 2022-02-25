using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Hub.PowerShell

function Get-SecretInfo
{
    [CmdletBinding()]
    param(
        [string] $Filter,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )
    
    $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
    Write-Verbose "Get-SecretInfo Vault: $VaultName" -Verbose:$verboseEnabled
    
    $hubParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    try{
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
    
        $hubEntries = [System.Collections.ArrayList]::new();
        foreach ($entry in (Get-HubEntry -VaultId $vaultId)) {
            if ($Filter -eq "*" -or $entry.Connection.Name -match $Filter) {
                $hubEntries.Add($entry);
                Write-Verbose "Added: $($entry.Connection.Name)" -Verbose:$verboseEnabled
            }
        }
    
        Write-Verbose "Found Entries: $($hubEntries.Count)" -Verbose:$verboseEnabled
    
        return $hubEntries | ForEach-Object {
            if ($_.Connection.Group -eq "") {
                $entryName = $_.Connection.Name
            }
            else {
                $entryName = $_.Connection.Group + "\" + $_.Connection.Name
            }

            [Microsoft.PowerShell.SecretManagement.SecretInformation]::new(
                $entryName, 
                [Microsoft.PowerShell.SecretManagement.SecretType]::PSCredential, # Get-Secret always returns PSCredential
                $VaultName,
                @{
                    EntryId = $_.Connection.ID
                }
            )
        } | Sort-Object -Property Name -Unique # Multiple entries with the same name are trimmed to prevent issue with SecretManagement
    }
    catch {
        Write-Error $_.Exception.Message
    }
    finally {
        Disconnect-DevolutionsHub($hubParameters);
    }
}
