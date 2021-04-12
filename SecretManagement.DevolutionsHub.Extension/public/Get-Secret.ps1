using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Hub.PowerShell

function Get-SecretInfo {
    [CmdletBinding()]
    param(
        [Alias('Name')][string]$Filter,
        [string]$VaultName = (Get-SecretVault).VaultName,
        [hashtable]$AdditionalParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    )

    try {
        Connect-DevolutionsHub('');  # review parameters

        $vaultId = $AdditionalParameters.VaultId;
        $secretName = $AdditionalParameters.Name;

        if (-not $secretName) {
            # prompt for entry name
        }

        $foundEntry;
        if (-not $vaultId) {
            foreach ($vault in Get-HubVault) {
                foreach ($entry in (Get-HubEntry -VaultId $vault.Id)) {
                    if ($vault.Name -eq $secretName) {
                        $foundEntry = $vault;
                        break;
                    }
                }
                if (! (-not $foundEntry)) {
                    # is empty
                    break;
                }
            }
        }
        else {
            foreach ($entry in (Get-HubEntry -VaultId $vaultId)) {
                if ($vault.Name -eq $secretName) {
                    $foundEntry = $vault;
                    break;
                }
            }
        }

        if (-not $foundEntry) {
            Write-Output "no entry found";
            # throw error
        }
        else {
            Write-Output $foundEntry.Id;
            # return credentials
        }
    }
    catch {
        Disconnect-DevolutionsHub('');  # review parameters
    }
}