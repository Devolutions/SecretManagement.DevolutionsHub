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
            ([Devolutions.Hub.PowerShell.Entities.Hub.PSDecryptedEntry]) {
                $newHubEntry = $secret
            }
            ([Devolutions.Generated.Models.Connection]) {
                $newHubEntry = [Devolutions.Hub.PowerShell.Entities.Hub.PSDecryptedEntry]@{ 
                    PsMetadata = [Devolutions.Hub.PowerShell.Entities.Hub.PSMetadata]@{ 
                        Name = $Name; 
                        ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Credential 
                    };
                    Connection = $secret
                }
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
        
        if (-not $newHubEntry) {
            $newHubEntry = [Devolutions.Hub.PowerShell.Entities.Hub.PSDecryptedEntry]@{ 
                PsMetadata = [Devolutions.Hub.PowerShell.Entities.Hub.PSMetadata]@{ 
                    Name = $Name; 
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
            $newHubEntry.PsMetadata.Name = $Name
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
