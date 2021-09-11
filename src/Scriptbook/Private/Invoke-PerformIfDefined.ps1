<#
.SYNOPSIS
Checks if command/action is defined in script / workflow before executing

.DESCRIPTION
Checks if command/action is defined in script / workflow before executing, In test mode only execute test actions from workflow

#>
function Invoke-PerformIfDefined
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string][alias('c')]$Command,
        $ThrowError = $false,
        $ActionParameters,
        [bool]$NoReEntry,
        [bool]$AsJob = $false,
        [switch]$NoDepends,
        [switch]$Test,
        [switch]$Manual
    )

    $ctx = Get-RootContext
    $action = $ctx.Actions[$Command.Replace('Invoke-', 'Action-')]
    if ($action)
    {
        if ($action.Disabled) { return }
        # in test mode only execute test actions from workflow
        # not in Test mode don't execute test actions
        if ($Test.IsPresent)
        {
            if ($action.TypeName -ne 'Test')
            {
                return
            }
        }
        else
        {
            if ($action.TypeName -eq 'Test')
            {
                return
            }
        }

        if ($ActionParameters) { $ap = $ActionParameters } else { $ap = $action.Parameters }
        if ($AsJob) { $aj = $true } else { $aj = $action.AsJob }
        #TODO/FIXME !!EH Put action into separate method?
        Invoke-Perform -Command $action.Name -Code $action.Code -Depends $action.Depends -ErrorAction $action.ErrorAction -ActionParameters @{Name = $action.DisplayName; ActionName = $action.DisplayName; Tag = $action.Tags; Parameters = $ap } -NoReEntry $NoReEntry -AsJob $aj -If $action.If -NoDepends:$NoDepends.IsPresent -WhatIf:$WhatIfPreference -NextAction $Action.NextAction -For $action.For -Parallel:$action.Parallel -Container:$action.Container -ContainerOptions:$action.ContainerOptions -Session $action.Session -Isolated:$action.Isolated -Manual:$Manual.IsPresent -TypeName $action.TypeName -RequiredVariables $action.RequiredVariables -Comment $action.Comment -SuppressOutput:$action.SuppressOutput
    }
    else
    {
        # in test mode only execute test functions from workflow
        # not in Test mode don't execute test functions
        if ($Test.IsPresent)
        {
            if (!$Command.ToLower().Contains('test'))
            {
                return
            }
        }
        else
        {
            if ($Command.ToLower().Contains('test'))
            {
                return
            }            
        }
        if (Get-Item function:$Command -ErrorAction SilentlyContinue)
        {
            Invoke-Perform -Command $Command -AsJob $AsJob -NoDepends:$NoDepends.IsPresent -WhatIf:$WhatIfPreference -TypeName 'Function'
        }
        elseif (Get-Item function:$($Command.Replace('Invoke-', '')) -ErrorAction SilentlyContinue)
        {
            Invoke-Perform -Command $Command.Replace('Invoke-', '') -AsJob $AsJob -NoDepends:$NoDepends.IsPresent -WhatIf:$WhatIfPreference -TypeName 'Function'
        }
        elseif ($ThrowError)
        {
            Throw "Action $($Command.Replace('Invoke-', '').Replace('Action-', '')) or Command $Command not found in ScriptFile(s)"
        }
    }
}
