[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Parameters -Name 'Params' {
    @{
        ParamOne = 'one'
        ParamTwo = 'two'
    }
}

Variables -Name 'Samples' {
    @{
        ParamThree = 'three'
    }
}

Action Hello {
    Write-Info "Hello $($Context.Params.ParamOne)"
    Write-Info "Hello $($Params.ParamOne)"
    $ctx = Get-WorkflowContext
    Write-Info "Hello $($ctx.Params.ParamOne)"
}

Action GoodBy {
    $Context.Samples.ParamThree = 33333
    Write-Info "GoodBy $($Context.Samples.ParamThree)"
    Write-Info "GoodBy $($Samples.ParamThree)"
    $ctx = Get-WorkflowContext
    Write-Info "Hello $($ctx.Samples.ParamThree)"
}

Start-Workflow -Name HelloWorkflow -WhatIf:$WhatIfPreference