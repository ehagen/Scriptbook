Set-Alias -Name Out-Info -Value Out-ScriptbookHost -Scope Global -Force -WhatIf:$false
function Out-ScriptbookHost
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]
        $InputObject
    )

    $InputObject | Out-Default
}