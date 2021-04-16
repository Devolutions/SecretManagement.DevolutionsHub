@{
    ModuleVersion = '0.0.1'
    RootModule = '.\SecretManagement.DevolutionsHub.Extension.psm1'
    # RequiredAssemblies = '..\publish\Devolutions.Hub.Powershell.dll'
    FunctionsToExport = @('Set-Secret','Get-Secret','Remove-Secret','Get-SecretInfo','Test-SecretVault')
}