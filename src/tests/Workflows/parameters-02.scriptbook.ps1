[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Parameters -Name 'Params' -Path './parameters.default-params.json' {
    @{
        ParamOne = 'one'
        ParamTwo = 'two'
        ParamSecret = (ConvertTo-SecureString -String ('zcd7d0fcc926f073dff81de2c??') -AsPlainText -Force)
    }
}

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