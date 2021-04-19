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
    
        $vaultId = $AdditionalParameters.VaultId;
        Write-Verbose "selected vault Id: $vaultId" -Verbose:$verboseEnabled
    
        $hubEntries = [System.Collections.ArrayList]::new();
        if (-not $vaultId) {
            foreach ($vault in Get-HubVault) {
                Write-Verbose $vault.Id -Verbose:$verboseEnabled
                foreach ($entry in (Get-HubEntry -VaultId $vault.Id)) {
                    $hubEntries.Add($entry);
                    Write-Verbose "Added: $($entry.Connection.Name)" -Verbose:$verboseEnabled
                }
            }
        } else {
            foreach ($entry in (Get-HubEntry -VaultId $vaultId)) {
                $hubEntries.Add($entry);
                Write-Verbose "Added: $($entry.Connection.Name)" -Verbose:$verboseEnabled
            }
        }
    
        Write-Verbose "Found Entries: $($hubEntries.Count)" -Verbose:$verboseEnabled
    
        return $hubEntries | ForEach-Object {
            [Microsoft.PowerShell.SecretManagement.SecretInformation]::new(
                $_.Connection.Name, 
                [Microsoft.PowerShell.SecretManagement.SecretType]::PSCredential,
                $VaultName,
                @{
                    Name = "ID"
                    Value = $_.Connection.ID
                }
            )
        } | Sort-Object -Property Name #-Unique (same name entries will cause issues)
    }
    catch {
        Write-Verbose $_.Exception.Message -Verbose:$verboseEnabled
    }
    finally {
        Disconnect-DevolutionsHub($hubParameters);
    }
}
