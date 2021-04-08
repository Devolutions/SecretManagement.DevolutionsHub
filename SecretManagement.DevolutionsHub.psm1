Import-Module 'Microsoft.PowerShell.SecretManagement'

Get-ChildItem "$PSScriptRoot/Extension" | ForEach-Object {
    Export-ModuleMember $_.BaseName;
    # https://powershellexplained.com/2017-05-27-Powershell-module-building-basics/
}