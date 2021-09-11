#Set-Alias -Name ActionSetup -Value TaskSetup -Scope Global -Force -WhatIf:$false
Set-Alias -Name Initialize-Action -Value TaskSetup -Scope Global -Force -WhatIf:$false
function TaskSetup
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$Setup
    )
    $Script:PsakeSetupTask = $Setup
}