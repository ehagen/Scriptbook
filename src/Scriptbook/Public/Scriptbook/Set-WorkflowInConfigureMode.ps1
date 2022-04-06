<#
.SYNOPSIS
Set the workflow in configure Mode and enables interactive use.

.DESCRIPTION
Set the workflow in configure Mode and enables interactive use. Enables reading Parameters from Console.

.PARAMETER Value
Set Configure Mode On/Off

.EXAMPLE

Set-WorkflowInConfigureMode $true

#>
function Set-WorkflowInConfigureMode
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [bool]$Value
    )

    if ($Value)
    {
        if (Get-IsPowerShellStartedInNonInteractiveMode)
        {
            Throw "Unable to set workflow in Configure Mode when running PowerShell in 'Non Interactive Mode'"
        }
    }

    $ctx = Get-WorkflowContext
    if ($PSCmdlet.ShouldProcess('Set-WorkflowInConfigureMode'))
    {
        $ctx.ConfigurePreference = $Value
        $Global:ConfigurePreference = $Value
    }
}