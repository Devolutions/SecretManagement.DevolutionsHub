Describe 'Remove-Secret' {
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

        $inRootHubEntry = New-HubEntry -VaultId $vaultId -PSDecryptedEntry $entryInRoot

        $entryFolder = [Devolutions.Hub.PowerShell.Entities.Hub.PSDecryptedEntry]@{ 
                PsMetadata = [Devolutions.Hub.PowerShell.Entities.Hub.PSMetadata]@{ 
                    Name = "pester-test"; 
                    ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Group
                };
                Connection = [Devolutions.Generated.Models.Connection]@{}
            }

        $folderHubEntry = New-HubEntry -VaultId $vaultId -PSDecryptedEntry $entryFolder

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

        $inFolderHubEntry = New-HubEntry -VaultId $vaultId -PSDecryptedEntry $entryInFolder
    }

    It 'removes an entry in root' {
        $entries = Get-SecretInfo -Vault $vault -Name "pester-root"
        if ($entries.Length -ne 1) {
            # should stop something is wrong
            $false | Should -Be $true
        }
        
        Remove-Secret -Vault $vault -Name $inRootHubEntry.Connection.ID;
        $entries = Get-SecretInfo -Vault $vault -Name "pester-root"
        $entries.Length | Should -Be 0
    }
    It 'removes an entry in a group' {
        $entries = Get-SecretInfo -Vault $vault -Name "pester-folder"
        if ($entries.Length -ne 1) {
            # should stop something is wrong
            $entries.Length | Should -Be 1
        }
        
        Remove-Secret -Vault $vault -Name $inFolderHubEntry.Connection.ID;
        $entries = Get-SecretInfo -Vault $vault -Name "pester-folder"
        $entries.Length | Should -Be 0
    }
    It 'removes folder' {
        $entries = Get-SecretInfo -Vault $vault -Name "pester-test"
        if ($entries.Length -ne 1) {
            # should stop something is wrong
            $false | Should -Be $true
        }

        Remove-Secret -Vault $vault -Name $folderHubEntry.Connection.ID;
        $entries = Get-SecretInfo -Vault $vault -Name "pester-test"
        $entries.Length | Should -Be 0
    }
}
