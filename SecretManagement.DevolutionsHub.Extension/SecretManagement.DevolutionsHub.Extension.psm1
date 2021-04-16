using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Hub.Powershell

Get-ChildItem "$PSScriptRoot/Private" | Foreach-Object {
    . $PSItem.FullName
}

$publicFunctions = Get-ChildItem "$PSScriptRoot/Public" | Foreach-Object {
    . $PSItem.FullName
    $PSItem.BaseName
}

Export-ModuleMember $publicFunctions