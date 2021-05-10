Describe 'Set-Secret' {
    BeforeAll {
        $vault = Read-Host 'Vault ';

        if (-not (Test-SecretVault -Name $vault)) {
            throw "Vault not configured properly"
        }
    }

    Context 'Secret location' {
        BeforeAll {
            $entryName = "pester-test-entry-00F09AEB"
            $folderName = "pester"
            $entryPass = "pass"
        }
        It 'sets an entry in root' {
            Set-Secret -Vault $vault -Name $entryName $entryPass
            $entry = Get-Secret -Vault $vault -Name $entryName
            ConvertFrom-SecureString -SecureString $entry.Password -AsPlainText | Should -Be $entryPass
        }
        It 'sets an entry in a group' {
            $groupedEntryName = $folderName + "\" + $entryName
            Set-Secret -Vault $vault -Name $groupedEntryName $entryPass
            $entry = Get-Secret -Vault $vault -Name $entryName
            ConvertFrom-SecureString -SecureString $entry.Password -AsPlainText | Should -Be $entryPass
        }
    }

    Context 'Secret using different password types' {
        BeforeAll {
            $secureString  = ConvertTo-SecureString -String $entryPass -AsPlainText
            $psCredential = [PSCredential]::new("pester", $secureString)

            $connection = [Devolutions.Generated.Models.Connection]@{ 
                Name           = $entryName;
                Group          = $folderName;
                ConnectionType = [Devolutions.Generated.Enums.ConnectionType]::Credential; 
                Credentials    = @{ 
                    CredentialType = [Devolutions.Generated.Enums.CredentialResolverConnectionType]::Default;
                    UserName       = $username;
                    # Domain         = "";
                    Password       = $password 
                }
            }
        }

        It 'sets an entry using PSCredential' {
            Set-Secret -Vault $vault -Name $($entryName + "-psCred") $psCredential
            $entry = Get-Secret -Vault $vault -Name $entryName
            ConvertFrom-SecureString -SecureString $entry.Password -AsPlainText | Should -Be $entryPass
        }
        It 'sets an entry using String' {
            Set-Secret -Vault $vault -Name $($entryName + "-string") $entryPass
            $entry = Get-Secret -Vault $vault -Name $entryName
            ConvertFrom-SecureString -SecureString $entry.Password -AsPlainText | Should -Be $entryPass
        }
        It 'sets an entry using SecureString' {
            Set-Secret -Vault $vault -Name $($entryName + "-secureString") $secureString
            $entry = Get-Secret -Vault $vault -Name $entryName
            ConvertFrom-SecureString -SecureString $entry.Password -AsPlainText | Should -Be $entryPass
        }
        It 'sets an entry using Devolutions.Generated.Models.Connection' {
            Set-Secret -Vault $vault -Name $($entryName + "-connection") $connection
            $entry = Get-Secret -Vault $vault -Name $entryName
            ConvertFrom-SecureString -SecureString $entry.Password -AsPlainText | Should -Be $entryPass
        }
    }

    AfterAll {
        Get-SecretInfo -Vault $vault -Name $entryName | ForEach-Object {
            Remove-Secret -Vault $vault -Name $_.Metadata.EntryId
        }
    }
}