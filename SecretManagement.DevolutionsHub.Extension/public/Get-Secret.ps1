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
                $group = $parsedName[0 .. ($parsedName.Length - 2)] | Join-String -Separator '\'
            }
            else {
                $group = ""
            }

            Write-Verbose "Looking for $($entryName) in $($group)" -Verbose:$verboseEnabled
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
            throw "Entry Not found"
        }
        else {
            if ($foundEntry.Connection.ConnectionType -ne "Credential") {
                Write-Verbose "Entry of type $($foundEntry.Connection.ConnectionType) was found" -Verbose:$verboseEnabled
                return [PSCredential]::Empty
            }

            if (($foundEntry.Connection.Credentials.UserName -eq "") -and ($foundEntry.Connection.Credentials.Password -eq "")) {
                Write-Verbose "Generating empty credentials" -Verbose:$verboseEnabled
                return [PSCredential]::Empty
            }

            $username = $foundEntry.Connection.Credentials.UserName
            if ($foundEntry.Connection.Credentials.Password -eq "") {
                Write-Verbose "Generating credentials with empty password" -Verbose:$verboseEnabled
                $securePassword = (new-object System.Security.SecureString)
            }
            else {
                $securePassword = ConvertTo-SecureString -String $foundEntry.Connection.Credentials.Password -AsPlainText
            }

            return New-Object PSCredential -ArgumentList ([pscustomobject] @{ UserName = $username; Password = $securePassword[0] }) 
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
    finally {
        Disconnect-DevolutionsHub($hubParameters);
    }
}
