<#
.SYNOPSIS
Enables action to execute

.DESCRIPTION
Enabled action to execute, can change during run-time

.PARAMETER Name
Name of the Action

#>
function Enable-Action([ValidateNotNullOrEmpty()][string]$Name)
{
    $ctx = Get-RootContext
    if ($ctx.Actions.Count -eq 0)
    {
        throw "No actions defined or workflow finished."
    }

    $action = $ctx.Actions["Action-$($Name.Replace('Action-',''))"]
    if ($action)
    {
        $action.Disabled = $false
    }
    else
    {
        throw "Action $Name not found in Enable-Action"
    }

}