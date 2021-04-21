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
        foreach ($entry in (Get-HubEntry -VaultId $vaultId)) {
            if ($Filter -eq "*" -or $entry.Connection.Name -match $Filter) {
                $hubEntries.Add($entry);
                Write-Verbose "Added: $($entry.Connection.Name)" -Verbose:$verboseEnabled
            }
        }
    
        Write-Verbose "Found Entries: $($hubEntries.Count)" -Verbose:$verboseEnabled
    
        return $hubEntries | ForEach-Object {
            [Microsoft.PowerShell.SecretManagement.SecretInformation]::new(
                $_.Connection.Name, 
                [Microsoft.PowerShell.SecretManagement.SecretType]::PSCredential, # Get-Secret always returns PSCredential
                $VaultName,
                @{
                    Name = "ID"
                    Value = $_.Connection.ID
                }
            )
        } | Sort-Object -Property Name
    }
    catch {
        Write-Verbose $_.Exception.Message -Verbose:$verboseEnabled
    }
    finally {
        Disconnect-DevolutionsHub($hubParameters);
    }
}
