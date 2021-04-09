using namespace Microsoft.PowerShell.SecretManagement

Get-ChildItem "$PSScriptRoot/public" | ForEach-Object {
    Export-ModuleMember $_.BaseName;
    # https://powershellexplained.com/2017-05-27-Powershell-module-building-basics/
}