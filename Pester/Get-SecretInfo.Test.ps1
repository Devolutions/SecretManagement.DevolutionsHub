Describe 'Get-SecretInfo' {
    BeforeAll {
        $vault = Read-Host 'Vault ';

        if (-not (Test-SecretVault -Name $vault)) {
            throw "Vault not configured properly"
        }

        $entryName = "pester-test-entry-00F09AEB"
        $folderName = "pester"
        $entryPass = "pass"
        
        Set-Secret -Vault $vault -Name $entryName $entryPass
        Set-Secret -Vault $vault -Name $($folderName + "\" + $entryName) $entryPass
    }

    It 'gets all secrets' {
        $entries = Get-SecretInfo -Vault hubSec
        $entries.Length | Should -BeGreaterThan 3
    }
    It 'gets secrets based on name' {
        $entries = Get-SecretInfo -Vault hubSec -Name $entryName
        $entries.Length | Should -Be 2
    }

    AfterAll {
        Get-SecretInfo -Vault $vault -Name $entryName | ForEach-Object {
            Remove-Secret -Vault $vault -Name $_.Metadata.EntryId
        }
    }
}