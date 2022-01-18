<#
.SYNOPSIS
Writes to the ConsoleHost

.DESCRIPTION
Writes to the ConsoleHost

.PARAMETER InputObject
Value to write to Console Host

.EXAMPLE

'Hello' | Out-ScriptbookHost

#>

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