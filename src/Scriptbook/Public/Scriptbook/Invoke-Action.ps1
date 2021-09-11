<#
.SYNOPSIS
Invokes an Action by name. If action is not found error is generated

.DESCRIPTION
Invokes an Action by name. If action is not found error is generated. Allows to call an Action in another Action scriptblock.

.PARAMETER Name
Name of Action

.EXAMPLE
Invoke-Action -Name Hello

#>

Set-Alias -Name Invoke-Step -Value Invoke-Action -Scope Global -Force -WhatIf:$false
function Invoke-Action([Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Name)
{
    $cnt = $script:InvokedCommands.Count
    Invoke-PerformIfDefined -Command "Action-$($Name.Replace('Action-',''))" -ThrowError $true -Manual
    if ($script:InvokedCommands.Count -eq ($cnt + 1) )
    {
        return $script:InvokedCommands[$cnt]
    }
    else
    {
        return $null
    }
}
