<#
.SYNOPSIS
Writes to the Verbose stream if -Verbose

.DESCRIPTION
Writes to the verbose stream if -Verbose present

.PARAMETER InputObject
Value to write to verbose stream

.EXAMPLE

'Hello' | Out-ScriptbookVerbose

#>

Set-Alias -Name Out-Null -Value Out-ScriptbookVerbose -Scope Global -Force -WhatIf:$false
function Out-ScriptbookVerbose
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseProcessBlockForPipelineCommand", "")]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [object]
        $InputObject
    )
    if ($InputObject)
    {
        $ctx = Get-RootContext
        if ($ctx.Verbose -or $Global:VerbosePreference -eq 'Continue' )
        {
            Write-Verbose ($InputObject | Out-String) -Verbose
        }
    }
}