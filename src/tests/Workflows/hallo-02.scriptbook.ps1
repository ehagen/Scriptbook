[CmdletBinding(SupportsShouldProcess = $True)]
Param(
    $FirstParam = 'First',
    $SecondParam = 'Second'
)

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Step Hello {
    Write-Info "Hello $FirstParam"
}

Step GoodBy {
    Write-Info "GoodBy $SecondParam, I am skipped"
}

Start-Workflow -Steps Hello, !Goodby -Name Hello -WhatIf:$WhatIfPreference