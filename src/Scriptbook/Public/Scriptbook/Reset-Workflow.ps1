<#
.SYNOPSIS
Resets the workflow global state/variables

.DESCRIPTION
Resets the workflow global state/variables and prepares for next workflow start in current session, enables support of multiple workflows in one session. Also used for unit testing purposes.

.EXAMPLE
Reset-Workflow

#>
function Reset-Workflow
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [switch]$Soft
    )

    if ($PSCmdlet.ShouldProcess("Reset-Workflow"))
    {
        $Script:RootContext = New-RootContext -WhatIf:$false -Soft:$Soft.IsPresent

        # compatibility with PSake
        $Script:PSakeProperties = $null
        $Script:PSakeInvocationParameters = $null
        $Script:PSakeInvocationProperties = $null
        $Script:PSakeSetupTask = $null
        $Script:PSakeTearDownTask = $null
    }
}