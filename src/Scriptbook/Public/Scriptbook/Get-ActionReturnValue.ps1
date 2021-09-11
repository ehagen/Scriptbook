<#
.SYNOPSIS
Returns Action return-value or the output written to output streams

.DESCRIPTION
Returns Action return-value or the output written to output streams. Each Action can return output for use in other Actions. Normally output is ignored and does not interfere with workflow

.PARAMETER Name
Name of the Action

#>
Set-Alias -Name Get-ActionOutput -Value Get-ActionReturnValue -Scope Global -Force -WhatIf:$false
Set-Alias -Name Get-ActionOutputValue -Value Get-ActionReturnValue -Scope Global -Force -WhatIf:$false
function Get-ActionReturnValue
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    param($Name)

    $ctx = Get-RootContext
    if ($ctx.Actions.Count -eq 0)
    {
        throw "No actions defined or workflow finished."
    }

    $returnValue = $null
    $action = $ctx.Actions["Action-$($Name.Replace('Action-',''))"]
    if ($action)
    {
        $script:InvokedCommandsResult | ForEach-Object { if ($_.Command -eq $action.Name) { $returnValue = $_.ReturnValue } }
    }
    else
    {
        throw "Action $Name not found in Get-ActionReturnValue"
    }
    return $returnValue
}