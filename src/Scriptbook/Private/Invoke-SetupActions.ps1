function Invoke-SetupActions
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

    foreach ($action in $Actions)
    {
        if ($action.TypeName -eq 'Setup' -and ($action.Name -notin $script:InvokedCommands) )
        {
            Invoke-PerformIfDefined -Command $action.Name -ThrowError $ThrowError -Test:$Test.IsPresent -WhatIf:$WhatIfPreference
        }
    }                    
}