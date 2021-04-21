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
        if (-not $vaultId) {
            $vaultId = Read-Host 'Hub Vault Id: ';
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
                $username = Read-Host 'Username: ';                
                $password = $Secret;
            }
            ([securestring]) {
                $username = Read-Host 'Username: ';
                $password = ConvertFrom-SecureString -SecureString $Secret -AsPlainText
            }
            default {
                throw [System.NotImplementedException] "Provided secret type not supported.";
            }
        }

        if (-not $newHubEntry) {
            $newHubEntry = [Devolutions.Generated.Models.Connection]@{ 
                Name           = $Name; 
                # Group
                ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Credential; 
                Credentials    = @{ 
                    CredentialType = [Devolutions.Generated.Enums.CredentialResolverConnectionType]::Default;
                    UserName       = $username;
                    # Domain         = "";
                    Password       = $password 
                }
            }
        }
    
        New-HubEntry -VaultId $vaultId -Connection $newHubEntry
        Write-Verbose "Entry Added" -Verbose:$verboseEnabled
    }
    catch {
        Write-Verbose $_.Exception.Message -Verbose:$verboseEnabled
    }
    finally {
        Disconnect-DevolutionsHub($hubParameters);
    }
}
