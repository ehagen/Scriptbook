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
    if (!(Get-Variable -Name Context -ErrorAction Ignore -Scope Global))
    {
        Set-Variable -Name Context -Value @{ } -Scope Global
    }
    return $Global:Context
}