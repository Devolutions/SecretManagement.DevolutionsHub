function Set-Secret
{
    param (
        [string] $Name,
        [object] $Secret,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )

    # get hub context

    if (-not $Name)
    {
        $Name = Read-Host 'Name: ';
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
            # prompt for username
            $password = $Secret;
        }
        ([securestring]) {
            # prompt for username
            $password = ConvertFrom-SecureString -SecureString $Secret -AsPlainText
        }
        default {
            throw [System.NotImplementedException] "Provided secret type not supported.";
        }
    }

    if (-not $newHubEntry) {
        $newHubEntry = [Devolutions.Generated.Models.Connection]@{ 
            Name = $Name; 
            ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Credential; 
            Credentials = @{ 
                CredentialType = [Devolutions.Generated.Enums.CredentialResolverConnectionType]::Default;
                UserName = $username;
                # Domain = "TestDomain";
                Password = $password 
            }
        }
    }
    New-HubEntry -VaultId $vaultId -Connection $newHubEntry
}