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
        Write-Verbose "Parsing entry name" -Verbose:$verboseEnabled
        try {
            $entryId = [System.Guid]::Parse($Name)
            $foundEntry = Get-HubEntry -VaultId $vaultId -EntryId $entryId
        }
        catch {
            $parsedName = $Name -split '\\'
            $entryName = $parsedName[$parsedName.Length - 1];
            if ($parsedName.Length -ge 2) {
                $group = $parsedName[0 .. ($parsedName.Length - 2)] | Join-String -Separator '\\'
            }

            Write-Verbose "Looking for $($entryName) in $($parsedName)" -Verbose:$verboseEnabled
            foreach ($entry in (Get-HubEntry -VaultId $vaultId)) {
                if ($entry.Connection.Group -eq $group -and $entry.Connection.Name -eq $entryName) {
                    $foundEntry = $entry;
                    Write-Verbose "Entry $Name was found" -Verbose:$verboseEnabled
                    break;
                }
            }
        }  

        if (-not $foundEntry) {
            Write-Verbose "No entry found" -Verbose:$verboseEnabled
            throw "Entry Not found";
        }
        else {
            if ($foundEntry.Connection.ConnectionType -ne "Credential") {
                Write-Verbose "Entry of type $($foundEntry.Connection.ConnectionType) was found" -Verbose:$verboseEnabled
            }

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