@{
    ModuleVersion = '0.3'
    RootModule = '.\SecretManagement.DevolutionsHub.Extension.psm1'
    FunctionsToExport = @('Set-Secret','Get-Secret','Remove-Secret','Get-SecretInfo','Test-SecretVault')
}