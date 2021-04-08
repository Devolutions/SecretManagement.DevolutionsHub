function Register-DevolutionsHubSecretVault
{
    param (
        [string] $Name,
        [string] $Url,
        [string] $ApplicationKey,
        [string] $ApplicationSecret
    )

    $PSHubContext = [Devolutions.Hub.PowerShell.Entities.PowerShell.PSHubContext]@{ApplicationKey=$ApplicationKey; ApplicationSecret=$ApplicationSecret; Url=$Url}
    Connect-HubAccount -PSHubContext $PSHubContext
    
    # Save param for later use
    Register-SecretVault -ModuleName "SecretManagement.DevolutionsHub" -Name $Name -VaultParameters @{

    }

    if (-not (Get-SecretVault -Name $name)) {
        throw 'SecretVault could not be registered properly'  # clean up error message
    }
}