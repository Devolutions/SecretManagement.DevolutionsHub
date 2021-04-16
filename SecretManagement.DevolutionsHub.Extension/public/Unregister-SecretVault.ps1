
function Unregister-SecretVault
{
    [CmdletBinding()]
    param (
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    # The Unregister-SecretVault cmdlet is optional and will be called on the extension vault if available. 
    # It is called before the extension vault is unregistered to allow it to perform any needed clean up work.
}
