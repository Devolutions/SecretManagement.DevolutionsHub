Describe 'Get-SecretInfo' {
    BeforeAll {
        $vault = Read-Host 'Vault ';

        if (-not (Test-SecretVault -Name $vault)) {
            throw "Vault not configured properly"
        }

        $vaultParameters = (Get-SecretVault -name $vault).VaultParameters

        $PSHubContext = [Devolutions.Hub.PowerShell.Entities.PowerShell.PSHubContext] @{
            ApplicationKey    = $vaultParameters.ApplicationKey; 
            ApplicationSecret = $vaultParameters.ApplicationSecret; 
            Url               = $vaultParameters.Url
        }

        $vaultId = $vaultParameters.VaultId;

        Connect-HubAccount -PSHubContext $PSHubContext;

        $entryName = "pester-test-entry-00F09AEB"
        $folderName = "pester"
        $entryPass = "pass"

        $entryInRoot = [Devolutions.Hub.PowerShell.Entities.Hub.PSDecryptedEntry]@{ 
                PsMetadata = [Devolutions.Hub.PowerShell.Entities.Hub.PSMetadata]@{ 
                    Name = "pester-root"; 
                    ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Credential 
                };
                Connection = [Devolutions.Generated.Models.Connection]@{ 
                    Credentials = [Devolutions.Generated.Models.CredentialsConnection]@{ 
                        CredentialType = [Devolutions.Generated.Enums.CredentialResolverConnectionType]::Default; 
                        UserName = "user";
                        Password = "pass"
                    } 
                } 
            }

        New-HubEntry -VaultId $vaultId -PSDecryptedEntry $entryInRoot

        $entryFolder = [Devolutions.Hub.PowerShell.Entities.Hub.PSDecryptedEntry]@{ 
                PsMetadata = [Devolutions.Hub.PowerShell.Entities.Hub.PSMetadata]@{ 
                    Name = $folderName; 
                    ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Group
                };
                Connection = [Devolutions.Generated.Models.Connection]@{}
            }

        $newFolder = New-HubEntry -VaultId $vaultId -PSDecryptedEntry $entryFolder

        $entryInFolder = [Devolutions.Hub.PowerShell.Entities.Hub.PSDecryptedEntry]@{ 
                PsMetadata = [Devolutions.Hub.PowerShell.Entities.Hub.PSMetadata]@{ 
                    Name = "pester-folder"; 
                    ParentId = $newFolder.Connection.ID;
                    ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Credential 
                };
                Connection = [Devolutions.Generated.Models.Connection]@{ 
                    Credentials = [Devolutions.Generated.Models.CredentialsConnection]@{ 
                        CredentialType = [Devolutions.Generated.Enums.CredentialResolverConnectionType]::Default; 
                        UserName = "user";
                        Password = "pass";
                    } 
                } 
            }

        $result = New-HubEntry -VaultId $vaultId -PSDecryptedEntry $entryInFolder
        Write-Host $result.Audit.CreatedDate
    }

    It 'gets all secrets' {
        $entries = Get-SecretInfo -Vault $vault
        $entries.Length | Should -Be 3
    }
    It 'gets secrets based on name' {
        $entries = Get-SecretInfo -Vault $vault -Name "pester-folder"
        $entries.Length | Should -Be 1
    }

    AfterAll {
        Get-SecretInfo -Vault $vault -Name $entryName | ForEach-Object {
            Remove-Secret -Vault $vault -Name $_.Metadata.EntryId
        }
    }
}
