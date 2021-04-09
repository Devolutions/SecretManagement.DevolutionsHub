using namespace Microsoft.PowerShell.SecretManagement
function Get-SecretInfo {
    [CmdletBinding()]
    param(
        [Alias('Name')][string]$Filter,
        [string]$VaultName = (Get-SecretVault).VaultName,
        [hashtable]$AdditionalParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    )
    
    # get hub context

    $vaultId = $AdditionalParameters.VaultId;

    $hubEntries = [System.Collections.ArrayList]::new();
    if (-not $vaultId) {
        foreach ($vault in Get-HubVault) {
            foreach ($entry in (Get-HubEntry -VaultId $vault.Id)) {
                $hubEntries.Add($entry);
            }
        }
    } else {
        foreach ($entry in (Get-HubEntry -VaultId $vaultId)) {
            $hubEntries.Add($entry);
        }
    }

    return $hubEntries | ForEach-Object {
        [Microsoft.PowerShell.SecretManagement.SecretInformation]::new(
            ($_.Connection), 
            [Microsoft.PowerShell.SecretManagement.SecretType]::PSCredential,
            $VaultName
        )
        New-Object -TypeName Microsoft.PowerShell.SecretManagement.SecretInformation -Property @{Name=$_.Name;  }
    } | Sort-Object -Property Name #-Unique (same name entries will cause issues)
}