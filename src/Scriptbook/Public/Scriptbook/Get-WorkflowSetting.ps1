<#
.SYNOPSIS
Retrieves one Workflow Setting

.DESCRIPTION
Retrieves one Workflow Setting like InTest mode

.PARAMETER Name
Name of Setting

.EXAMPLE

Get-WorkflowSetting -Name 'InTest'

#>
function Get-WorkflowSetting([ValidateNotNullOrEmpty()]$Name)
{
    $ctx = Get-RootContext
    if ($Name -eq 'InTest')
    {
        return $ctx.InTest
    }
    else
    {
        Throw "Workflow Setting '$Name' not recognized"
    }
}