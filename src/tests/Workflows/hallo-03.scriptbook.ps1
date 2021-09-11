[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Hello -Tag hello {
    Write-Info "Hello"
}

Action GoodBy -Depends Hello {
    Write-Info "GoodBy"
}

# use dependencies
Start-Workflow Goodby -Name Hello -WhatIf:$WhatIfPreference