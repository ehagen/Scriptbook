[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Hello {
    Write-Info "Hello"
}

Action GoodBy {
    Write-Info "GoodBy"
}

Start-Workflow -Name HelloWorkflow -WhatIf:$WhatIfPreference