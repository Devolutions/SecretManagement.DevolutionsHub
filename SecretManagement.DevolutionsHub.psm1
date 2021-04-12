$publicFunctions = Get-ChildItem "$PSScriptRoot/Public" | Foreach-Object {
    . $PSItem.FullName
    $PSItem.BaseName
}

Export-ModuleMember $publicFunctions