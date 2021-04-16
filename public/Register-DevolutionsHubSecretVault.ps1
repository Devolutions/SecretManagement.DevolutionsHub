
function Register-DevolutionsHubSecretVault
{
    [CmdletBinding()]
    param(
        [string] $Name,
        [string] $Url,
        [string] $ApplicationKey,
        [string] $ApplicationSecret
    )

    $PSHubContext = [Devolutions.Hub.PowerShell.Entities.PowerShell.PSHubContext]@{
        ApplicationKey = $ApplicationKey;
        ApplicationSecret = $ApplicationSecret;
        Url = $Url;
    }

    Connect-HubAccount -PSHubContext $PSHubContext
    
    $ModuleName = 'SecretManagement.DevolutionsHub'

    Register-SecretVault -ModuleName $ModuleName -Name $Name -VaultParameters @{}

    if (-not (Get-SecretVault -Name $name)) {
        throw 'SecretVault could not be registered properly'  # clean up error message
    }
}
