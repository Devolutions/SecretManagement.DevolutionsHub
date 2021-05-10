Describe 'Get-Secret' {
    BeforeAll {
        $vault = Read-Host 'Vault ';

        if (-not (Test-SecretVault -Name $vault)) {
            throw "Vault not configured properly"
        }
    }

    context 'Get credential' {
        It 'gets entry by Id' {
            $username = "SecretUser"
            $entry = Get-Secret -Vault hubSec -Name "737ae683-1825-4394-b7bb-a04b87867cd0"
            $entry.UserName | Should -Be $username
        }
        It 'gets entry by name' {
            $username = "SecretUser"
            $entry = Get-Secret -Vault hubSec -Name "Secret"
            $entry.UserName | Should -Be $username
        }
        It 'gets entry by name in a folder' {
            $username = "GroupUser"
            $entry = Get-Secret -Vault hubSec -Name "Pester\Folder\Folder-Secret"
            $entry.UserName | Should -Be $username
        }
        It 'gets entry by name in a virtual folder' {
            $username = "VirtualUser"
            $entry = Get-Secret -Vault hubSec -Name "Pester\Virtual\Virtual-Secret"
            $entry.UserName | Should -Be $username
        }
    }

    context 'Get partial credential' {
        It 'gets entry without username' {
            $entry = Get-Secret -Vault hubSec -Name "noUser"
            $entry | Should -Not -Be $null
            $entry.UserName | Should -Be ""
            $entry.Password | Should -Not -Be $null
        }
        It 'gets entry without password' {
            $entry = Get-Secret -Vault hubSec -Name "noPass"
            $entry | Should -Not -Be $null
            $entry.UserName | Should -Not -Be $null
            $entry.Password | Should -Not -Be $null
        }
        It 'gets entry without credentials' {
            $entry = Get-Secret -Vault hubSec -Name "noCred"
            $entry | Should -Not -Be $null
            $entry.UserName | Should -Be $null
            $entry.Password | Should -Be $null
        }
    }
}