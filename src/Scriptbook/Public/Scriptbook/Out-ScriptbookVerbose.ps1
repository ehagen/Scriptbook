<#
.SYNOPSIS
Writes to the Verbose stream if -Verbose

.DESCRIPTION
Writes to the verbose stream if -Verbose present

.PARAMETER InputObject
Value to write to verbose stream

.EXAMPLE

'Hello' | Out-ScriptbookVerbose

or 

'Hello' | Out-NullSb

#>

Set-Alias -Name Out-NullSb -Value Out-ScriptbookVerbose -Scope Global -Force -WhatIf:$false -ErrorAction Ignore
Set-Alias -Name Out-Verbose -Value Out-ScriptbookVerbose -Scope Global -Force -WhatIf:$false -ErrorAction Ignore
function Out-ScriptbookVerbose
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseProcessBlockForPipelineCommand", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingEmptyCatchBlock", "")]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [object]
        $InputObject
    )
    if ($InputObject)
    {
        try
        {
            if ($Global:VerbosePreference -eq 'Continue')
            {
                Write-Verbose ($InputObject | Out-String) -Verbose
            }
            elseif ($Script:RootContext)
            {
                $ctx = Get-RootContext
                if ($ctx.Verbose)
                {
                    Write-Verbose ($InputObject | Out-String) -Verbose
                }
            }
        }
        catch
        {
            # no exception in catch 'Out-NullSb' ever
        }
    }
}