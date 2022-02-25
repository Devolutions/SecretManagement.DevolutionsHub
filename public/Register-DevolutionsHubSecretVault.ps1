
function Register-DevolutionsHubSecretVault
{
    [CmdletBinding()]
    param(
        [string] $Name,
        [string] $Url,
        [string] $ApplicationKey,
        [string] $ApplicationSecret,
        [string] $Vault
    )

    $PSHubContext = [Devolutions.Hub.PowerShell.Entities.PowerShell.PSHubContext]@{
        ApplicationKey = $ApplicationKey;
        ApplicationSecret = $ApplicationSecret;
        Url = $Url;
    }

    $context = Connect-HubAccount -PSHubContext $PSHubContext 

    if (-not $context) {
        Write-Error "Hub credentials are invalid"
        return
    }

    Write-Verbose "Parsing VaultId" -Verbose:$verboseEnabled
    try {
        $vaultId = [System.Guid]::Parse($Vault)
        Write-Verbose "$vaultId" -Verbose:$verboseEnabled
    }
    catch {
        Write-Verbose "VaultId is not a valid GUID. Looking for Vault with name: $Vault" -Verbose:$verboseEnabled

        foreach ($hubVault in Get-HubVault) {
            if ($hubVault.Name -eq $Vault) {
                $vaultId = $hubVault.Id 
                break;
            }
        }
    }

    if (-not $vaultId) {
        throw 'Vault could not be found'
    }
    
    $ModuleName = 'SecretManagement.DevolutionsHub'

    Register-SecretVault -ModuleName $ModuleName -Name $Name -VaultParameters @{
        Url = $Url
        ApplicationKey = $ApplicationKey
        ApplicationSecret = $ApplicationSecret
        VaultId = $vaultId
    }

    if (-not (Get-SecretVault -Name $name)) {
        throw 'SecretVault could not be registered properly'
    }
}
