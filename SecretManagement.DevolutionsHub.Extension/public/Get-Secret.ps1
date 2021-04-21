using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Hub.PowerShell

function Get-Secret {
    [CmdletBinding()]
    param(
        [string] $Name,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
    Write-Verbose "Get-Secret Vault: $VaultName" -Verbose:$verboseEnabled

    $hubParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    try {
        Connect-DevolutionsHub($VaultName, $hubParameters);

        $vaultId = $hubParameters.VaultId;

        Write-Verbose $Name -Verbose:$verboseEnabled

        $foundEntry = $null;
        # vaultId should always be set
        if (-not $vaultId) {
            foreach ($vault in Get-HubVault) {                
                Write-Verbose $vault.Id -Verbose:$verboseEnabled
                foreach ($entry in (Get-HubEntry -VaultId $vault.Id)) {
                    if ($entry.Connection.Name -eq $Name) {
                        $foundEntry = $entry;
                        Write-Verbose "Entry $Name was found" -Verbose:$verboseEnabled
                        break;
                    }
                }
                
                if ($foundEntry) {
                    # found
                    break;
                }
            }
        }
        else {
            Write-Verbose "Parsing entry name" -Verbose:$verboseEnabled
            try {
                $entryId = [System.Guid]::Parse($Name)
                $foundEntry = Get-HubEntry -VaultId $vaultId -EntryId $entryId
            }
            catch {
                foreach ($entry in (Get-HubEntry -VaultId $vaultId)) {
                    if ($entry.Connection.Name -eq $Name) {
                        $foundEntry = $entry;
                        Write-Verbose "Entry $Name was found" -Verbose:$verboseEnabled
                        break;
                    }
                }
            }       
        }

        if (-not $foundEntry) {
            Write-Verbose "no entry found" -Verbose:$verboseEnabled
            throw "Entry Not found";
        }
        else {
            $securePassword = ConvertTo-SecureString -String $foundEntry.Connection.Credentials.Password -AsPlainText;
            return [PSCredential]::new($foundEntry.Connection.Credentials.UserName, $securePassword);
        }
    }
    catch {
        Write-Verbose $_.Exception.Message -Verbose:$verboseEnabled
    }
    finally {
        Disconnect-DevolutionsHub($hubParameters);
    }
}