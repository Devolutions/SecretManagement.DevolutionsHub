using namespace Microsoft.PowerShell.SecretManagement
using namespace Devolutions.Hub.PowerShell

function Get-SecretInfo
{
    [CmdletBinding()]
    param(
        [string] $Filter,
        [string] $VaultName,
        [hashtable] $AdditionalParameters
    )
    
    $verboseEnabled = $AdditionalParameters.ContainsKey('Verbose') -and ($AdditionalParameters['Verbose'] -eq $true)
    Write-Verbose "[TestLocalScript.Extension]:Get-SecretInfo successfully called for vault: $VaultName" -Verbose:$verboseEnabled

    Write-Verbose $AdditionalParameters.ApplicationKey.Substring(0,8) -Verbose:$verboseEnabled

    Write-Verbose "(Get-SecretVault -Name $VaultName)" -Verbose:$verboseEnabled
    $hubParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    
    # get hub context
    Connect-DevolutionsHub($VaultName, $hubParameters);

    $vaultId = $AdditionalParameters.VaultId;
    Write-Verbose "selected vault Id: $vaultId" -Verbose:$verboseEnabled #

    $hubEntries = [System.Collections.ArrayList]::new();
    if (-not $vaultId) {
        foreach ($vault in Get-HubVault) {
            Write-Verbose $vault.Id -Verbose:$verboseEnabled #
            foreach ($entry in (Get-HubEntry -VaultId $vault.Id)) {
                $hubEntries.Add($entry);
            }
        }
    } else {
        foreach ($entry in (Get-HubEntry -VaultId $vaultId)) {
            $hubEntries.Add($entry);
        }
    }

    Write-Verbose $hubEntries.Count -Verbose:$verboseEnabled #

    return $hubEntries | ForEach-Object {
        [Microsoft.PowerShell.SecretManagement.SecretInformation]::new(
            ($_.Connection), 
            [Microsoft.PowerShell.SecretManagement.SecretType]::PSCredential,
            $VaultName
        )
        New-Object -TypeName Microsoft.PowerShell.SecretManagement.SecretInformation -Property @{Name=$_.Name;  }
    } | Sort-Object -Property Name #-Unique (same name entries will cause issues)
}
