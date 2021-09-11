<#
.SYNOPSIS
Disables action to execute

.DESCRIPTION
Disables action to execute, can change during run-time

.PARAMETER Name
Name of the Action

#>
function Disable-Action([ValidateNotNullOrEmpty()][string]$Name)
{
    $ctx = Get-RootContext
    if ($ctx.Actions.Count -eq 0)
    {
        throw "No actions defined or workflow finished."
    }

    $action = $ctx.Actions["Action-$($Name.Replace('Action-',''))"]
    if ($action)
    {
        $action.Disabled = $true
    }
    else
    {
        throw "Action $Name not found in Disable-Action"
    }

}
