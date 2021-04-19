using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Hub.PowerShell

function Get-Secret
{
    [CmdletBinding()]
    param(
        [string] $Name,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
    Write-Verbose "Get-Secret Vault: $VaultName" -Verbose:$verboseEnabled

    try {
        Write-Verbose 'Connecting to Hub' -Verbose:$verboseEnabled #
        $hubParameters = (Get-SecretVault -Name $VaultName).VaultParameters
        #Connect-DevolutionsHub($VaultName, $hubParameters);  # review parameters    
        $PSHubContext = [Devolutions.Hub.PowerShell.Entities.PowerShell.PSHubContext] @{
            ApplicationKey=$hubParameters.ApplicationKey; 
            ApplicationSecret=$hubParameters.ApplicationSecret; 
            Url=$hubParameters.Url
        }    
        Connect-HubAccount -PSHubContext $PSHubContext;
        Write-Verbose 'Connected to Hub' -Verbose:$verboseEnabled #

        $vaultId = $hubParameters.VaultId;

        Write-Verbose $Name -Verbose:$verboseEnabled #

        $foundEntry = $null;
        if (-not $vaultId) {
            foreach ($vault in Get-HubVault) {                
                Write-Verbose $vault.Id -Verbose:$verboseEnabled #
                foreach ($entry in (Get-HubEntry -VaultId $vault.Id)) {
                    if ($entry.Connection.Name -eq $Name) {
                        $foundEntry = $entry;
                        Write-Verbose "Entry $Name was found" -Verbose:$verboseEnabled #
                        break;
                    }
                }
                
                if ($foundEntry){
                    # found
                    break;
                }
            }
        }
        else {
            foreach ($entry in (Get-HubEntry -VaultId $vaultId)) {
                if ($entry.Connection.Name -eq $Name) {
                    $foundEntry = $entry;
                    Write-Verbose "Entry $Name was found" -Verbose:$verboseEnabled #
                    break;
                }
            }
        }

        if (-not $foundEntry) {
            Write-Verbose "no entry found" -Verbose:$verboseEnabled #
            throw "Entry Not found";
        }
        else {
            $securePassword = ConvertTo-SecureString -String $foundEntry.Connection.Credentials.Password -AsPlainText;
            return [PSCredential]::new($foundEntry.Connection.Credentials.UserName, $securePassword);
        }
    }
    catch {
        $errorMessage = $_.Exception.Message;
        Write-Verbose $errorMessage -Verbose:$verboseEnabled
    }
    finally {
        #Disconnect-DevolutionsHub($hubParameters);  # review parameters
        Disconnect-HubAccount -ApplicationKey $hubParameters.ApplicationKey;
    }
}