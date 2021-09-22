[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Hello -Tag hello -ErrorAction Continue {
    Write-Info "Hello"
    Throw "Error in Hello"
}

Action GoodBy -Depends Hello {
    Write-Info "GoodBy"
}

Action Also -Depends Hello -if { !(Get-ActionState -Name Hello).HasError } {
    Write-Info "Also"
}

# use dependencies
Start-Workflow -Name Hello -WhatIf:$WhatIfPreference