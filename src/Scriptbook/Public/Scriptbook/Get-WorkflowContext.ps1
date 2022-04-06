<#
.SYNOPSIS
Retrieves Workflow Context

.DESCRIPTION
Retrieves Workflow Context

.EXAMPLE

$ctx = Get-WorkflowContext

#>
function Get-WorkflowContext
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    param()
    
    if (!(Get-Variable -Name Context -ErrorAction Ignore -Scope Global))
    {
        Set-Variable -Name Context -Value @{ } -Scope Global -WhatIf:$false
    }
    return $Global:Context
}