[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Import-Parameters ./parameters.to-import.ps1

Variables -Name 'Samples' {
    @{
        ParamThree = 'three'
    }
}

Action Hello {
    $ctx = Get-WorkflowContext
    Write-Info "Hello $($ctx.Params.ParamOne)"
    Write-Info "Hello $($ctx.Params.ParamTwo)"
}

Action GoodBy {
    $ctx = Get-WorkflowContext
    Write-Info "GoodBy $($ctx.Samples.ParamThree)"
}

Start-Workflow -Name HelloWorkflow -WhatIf:$WhatIfPreference