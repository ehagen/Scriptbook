[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Hello -Tag hello {
    Write-Info "Hello"
    throw "Error in Hello"
}

Action GoodBy -Depends Hello {
    Write-Info "GoodBy"
}

Action Also -Depends Hello -Always {
    Write-Info "Also"
}

# use dependencies
Start-Workflow -Name Hello -WhatIf:$WhatIfPreference