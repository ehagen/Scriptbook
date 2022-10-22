[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force -Args @{ Quiet = $true }

Action Hello {
    Write-Info "Hello"
}

Action GoodBy {
    Write-Info "GoodBy"
}

Start-Workflow -Name HelloWorkflow -WhatIf:$WhatIfPreference -NoLogging -NoReport