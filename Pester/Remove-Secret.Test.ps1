Describe 'Remove-Secret' {
    BeforeAll {
        $vault = Read-Host 'Vault ';

        if (-not (Test-SecretVault -Name $vault)) {
            throw "Vault not configured properly"
        }

        $entryName = "pester-test-entry-00F09AEB"
        $folderName = "pester"
    }

    It 'removes an entry in root' {
        Set-Secret -Vault $vault -Name $entryName "pass"
        $entries = Get-SecretInfo -Vault $vault -Name $entryName 
        if ($entries.Length -ne 1) {
            # should stop something is wrong
            $false | Should -Be $true
        }
        
        Remove-Secret -Vault $vault -Name $entries[0].Metadata.EntryId
        $entries = Get-SecretInfo -Vault $vault -Name $entryName 
        $entries.Length | Should -Be 0
    }
    It 'removes an entry in a group' {
        $groupedEntryName = $folderName + "\" + $entryName
        Set-Secret -Vault $vault -Name $groupedEntryName "pass"
        $entries = Get-SecretInfo -Vault $vault -Name $entryName
        if ($entries.Length -ne 1) {
            # should stop something is wrong
            $entries.Length | Should -Be 1
        }
        
        Remove-Secret -Vault $vault -Name $entries[0].Metadata.EntryId
        $entries = Get-SecretInfo -Vault $vault -Name $entryName 
        $entries.Length | Should -Be 0
    }
}
