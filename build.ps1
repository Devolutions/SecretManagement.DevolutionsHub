$module = 'SecretManagement.DevolutionsHub'
Push-Location $PSScriptRoot

Remove-Item -Path .\package -Recurse -Force -ErrorAction SilentlyContinue

New-Item -Path "$PSScriptRoot\package\$module" -ItemType 'Directory' -Force | Out-Null
@('public', 'resources', 'SecretManagement.DevolutionsHub.Extension') | ForEach-Object {
    New-Item -Path "$PSScriptRoot\package\$module\$_" -ItemType 'Directory' -Force | Out-Null
    Copy-Item "$PSScriptRoot\$_" -Destination "$PSScriptRoot\package\$module" -Recurse -Force
}

Copy-Item "$PSScriptRoot\$module.psd1" -Destination "$PSScriptRoot\package\$module" -Force
Copy-Item "$PSScriptRoot\$module.psm1" -Destination "$PSScriptRoot\package\$module" -Force