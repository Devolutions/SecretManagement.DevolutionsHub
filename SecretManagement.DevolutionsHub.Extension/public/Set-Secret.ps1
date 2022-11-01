using namespace Devolutions.Hub.PowerShell

function Set-Secret {
    [CmdletBinding()]
    param (
        [string] $Name,
        [object] $Secret,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
    Write-Verbose "Set-Secret Vault: $VaultName" -Verbose:$verboseEnabled

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

        switch ($Secret.GetType()) {
            ([Devolutions.Generated.Models.Connection]) {
                $newHubEntry = $Secret;
            }
            ([pscredential]) {
                $username = $Secret.Username;
                $password = ConvertFrom-SecureString -SecureString $Secret.Password -AsPlainText;
            }
            ([String]) {
                $username = Read-Host 'Username ';                
                $password = $Secret;
            }
            ([securestring]) {
                $username = Read-Host 'Username ';
                $password = ConvertFrom-SecureString -SecureString $Secret -AsPlainText
            }
            default {
                throw [System.NotImplementedException] "Provided secret type not supported.";
            }
        }

        $parsedName = $Name -split '\\'
        $entryName = $parsedName[$parsedName.Length - 1];
        if ($parsedName.Length -ge 2) {
            $group = $parsedName[0 .. ($parsedName.Length - 2)] | Join-String -Separator '\'
        }
        
        if (-not $newHubEntry) {
            $newHubEntry = [Devolutions.Hub.PowerShell.Entities.Hub.PSDecryptedEntry]@{ 
                PsMetadata = [Devolutions.Hub.PowerShell.Entities.Hub.PSMetadata]@{ 
                    Name = $entryName; 
                    ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Credential 
                };
                Connection = [Devolutions.Generated.Models.Connection]@{ 
                    Credentials = [Devolutions.Generated.Models.CredentialsConnection]@{ 
                        CredentialType = [Devolutions.Generated.Enums.CredentialResolverConnectionType]::Default; 
                        UserName = $username;
                        Password = $password
                    } 
                } 
            }
        }
        else {
            $newHubEntry.Name = $entryName
            $newHubEntry.Group = $group
        }
    
        New-HubEntry -VaultId $vaultId -PSDecryptedEntry $newHubEntry
        Write-Verbose "Entry Added" -Verbose:$verboseEnabled
    }
    catch {
        Write-Error $_.Exception.Message
    }
    finally {
        Disconnect-DevolutionsHub($hubParameters);
    }
}
