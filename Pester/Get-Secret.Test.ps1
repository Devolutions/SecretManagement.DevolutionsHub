Describe 'Get-Secret' {
    BeforeAll {
        $vault = Read-Host 'Vault ';

        if (-not (Test-SecretVault -Name $vault)) {
            throw "Vault not configured properly"
        }

        # get vaultId from $vault parameters
        # $vaultId = 'd000b7bf-4403-4fb1-9409-b8f75c3a4438'

        $PesterGroup = [Devolutions.Hub.PowerShell.Entities.Hub.PSDecryptedEntry]@{ 
            PsMetadata = [Devolutions.Hub.PowerShell.Entities.Hub.PSMetadata]@{ 
                Name = 'Pester'; 
                ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Group 
            };
            Connection = [Devolutions.Generated.Models.Connection]@{ } 
        }

        $hubPesterGroup = New-HubEntry -VaultId $vaultId -PSDecryptedEntry $PesterGroup
        $parentId = $hubPesterGroup.Connection.ID
    }

    context 'Get credential' {
        BeforeAll {
            $entry = [Devolutions.Hub.PowerShell.Entities.Hub.PSDecryptedEntry]@{ 
                PsMetadata = [Devolutions.Hub.PowerShell.Entities.Hub.PSMetadata]@{ 
                    Name = 'PesterEntry'; 
                    ParentId = $parentId;
                    ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Credential 
                };
                Connection = [Devolutions.Generated.Models.Connection]@{ 
                    Credentials = [Devolutions.Generated.Models.CredentialsConnection]@{ 
                        CredentialType = [Devolutions.Generated.Enums.CredentialResolverConnectionType]::Default; 
                        UserName = "username123"
                        Password = "password123"
                    } 
                } 
            }

            New-HubEntry -VaultId $vaultId -PSDecryptedEntry $entry
        }

        It 'gets entry by Id' {
            $username = "SecretUser"
            $entry = Get-Secret -Vault hubSec -Name $entry.Connection.ID
            $entry.UserName | Should -Be "username123"
        }
        It 'gets entry by name' {
            $username = "SecretUser"
            $entry = Get-Secret -Vault hubSec -Name $entry.Connection.Name
            $entry.UserName | Should -Be "username123"
        }
    }

    context 'Get partial credential' {
        BeforeAll {
            $noCred = [Devolutions.Hub.PowerShell.Entities.Hub.PSDecryptedEntry]@{ 
                PsMetadata = [Devolutions.Hub.PowerShell.Entities.Hub.PSMetadata]@{ 
                    Name = 'noCred'; 
                    ParentId = $parentId;
                    ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Credential 
                };
                Connection = [Devolutions.Generated.Models.Connection]@{ 
                    Credentials = [Devolutions.Generated.Models.CredentialsConnection]@{ 
                        CredentialType = [Devolutions.Generated.Enums.CredentialResolverConnectionType]::Default; 
                    } 
                } 
            }
    
            $noUser = [Devolutions.Hub.PowerShell.Entities.Hub.PSDecryptedEntry]@{ 
                PsMetadata = [Devolutions.Hub.PowerShell.Entities.Hub.PSMetadata]@{ 
                    Name = 'noUser'; 
                    ParentId = $parentId;
                    ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Credential 
                };
                Connection = [Devolutions.Generated.Models.Connection]@{ 
                    Credentials = [Devolutions.Generated.Models.CredentialsConnection]@{ 
                        CredentialType = [Devolutions.Generated.Enums.CredentialResolverConnectionType]::Default; 
                        Password = "noUser_Password"
                    } 
                } 
            }
    
            $noPass = [Devolutions.Hub.PowerShell.Entities.Hub.PSDecryptedEntry]@{ 
                PsMetadata = [Devolutions.Hub.PowerShell.Entities.Hub.PSMetadata]@{ 
                    Name = 'noPass'; 
                    ParentId = $parentId;
                    ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Credential 
                };
                Connection = [Devolutions.Generated.Models.Connection]@{ 
                    Credentials = [Devolutions.Generated.Models.CredentialsConnection]@{ 
                        CredentialType = [Devolutions.Generated.Enums.CredentialResolverConnectionType]::Default; 
                        UserName = "noPass_Username"
                    } 
                } 
            }
    
            $UserPass = [Devolutions.Hub.PowerShell.Entities.Hub.PSDecryptedEntry]@{ 
                PsMetadata = [Devolutions.Hub.PowerShell.Entities.Hub.PSMetadata]@{ 
                    Name = 'UserPass'; 
                    ParentId = $parentId;
                    ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Credential 
                };
                Connection = [Devolutions.Generated.Models.Connection]@{ 
                    Credentials = [Devolutions.Generated.Models.CredentialsConnection]@{ 
                        CredentialType = [Devolutions.Generated.Enums.CredentialResolverConnectionType]::Default; 
                        UserName = "username123"
                        Password = "password123"
                    } 
                } 
            }

            $noCredEntry = New-HubEntry -VaultId $vaultId -PSDecryptedEntry $noCred
            $noUserEntry = New-HubEntry -VaultId $vaultId -PSDecryptedEntry $noUser
            $noPassEntry = New-HubEntry -VaultId $vaultId -PSDecryptedEntry $noPass
            $UserPassEntry = New-HubEntry -VaultId $vaultId -PSDecryptedEntry $UserPass
        }

        It 'gets entry without username' {
            $entry = Get-Secret -Vault hubSec -Name $noUserEntry.Connection.ID
            $entry | Should -Not -Be $null
            $entry.UserName | Should -Be ""
            $entry.Password | Should -Not -Be $null
        }
        It 'gets entry without password' {
            $entry = Get-Secret -Vault hubSec -Name $noPassEntry.Connection.ID
            $entry | Should -Not -Be $null
            $entry.UserName | Should -Not -Be $null
            $entry.Password | Should -Not -Be $null
        }
        It 'gets entry without credentials' {
            $entry = Get-Secret -Vault hubSec -Name $noCredEntry.Connection.ID
            $entry | Should -Not -Be $null
            $entry.UserName | Should -Be $null
            $entry.Password | Should -Be $null
        }
    }

    AfterAll {
        Remove-HubEntry -VaultId $vaultId -EntryId $parentId
    }
}
