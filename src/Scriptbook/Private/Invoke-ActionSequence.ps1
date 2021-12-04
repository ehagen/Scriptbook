function Invoke-ActionSequence
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "")]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        $Actions,
        $ThrowError = $false,
        [switch]$Test,
        [switch]$Parallel
    )

    if ($null -eq $Actions -or ($Actions.Count -eq 0))
    {
        Write-Verbose "No actions/steps found to execute"
        return
    }

    if ($Parallel.IsPresent -and $PSVersionTable.PSVersion.Major -ge 7)
    {
        $hasDepends = $false
        foreach ($action in $Actions)
        {
            if ($action.Depends.Count -gt 0)
            {
                $hasDepends = $true
            }
        }

        Write-Experimental "Starting workflow in parallel mode"
        #TODO !!EH disabled for now, not working yet
        $hasDepends = $true
        if (!$HasDepends)
        {
            $mp = (Get-Module Scriptbook).Path
            $globalScriptVariables = Get-GlobalVarsForScriptblock -AsHashTable
            $rc = Get-RootContext
            $Actions | Where-Object { $_.NoSequence -eq $false} | ForEach-Object -Parallel {
                $vars = $using:globalScriptVariables
                foreach ($v in $vars.GetEnumerator())
                {
                    Set-Variable $v.Key -Value $v.Value -Option ReadOnly -ErrorAction Ignore
                }
                Import-Module $using:mp -Args @{ Quiet = $true }
                $script:RootContext = $using:rc
                Invoke-PerformIfDefined -Command $_.Name -ThrowError $ThrowError -Test:$Test.IsPresent -WhatIf:$WhatIfPreference
            }
            return
        }
    }

    # sequential
    foreach ($action in $Actions)
    {
        if (!$action.NoSequence)
        {
            Invoke-PerformIfDefined -Command $action.Name -ThrowError $ThrowError -Test:$Test.IsPresent -WhatIf:$WhatIfPreference
        }
    }                    
}