<#
.SYNOPSIS
Say Doc Workflow

.DESCRIPTION
Say Doc Workflow which shows the documentation output
#>
[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Hello {
<#
.SYNOPSIS
Action Hello

.DESCRIPTION
Action Hello Show Information about Hello
#>

    Write-Info "Hello"
}

Action GoodBy {
<#
.SYNOPSIS
Action GoodBy

.DESCRIPTION
Action Hello Show Information about GoodBy
#>

    Write-Info "GoodBy"

<#

.REMARK
Will not be last action
#>
}

Action AlmostFinished {
    # We are almost finished
    # One more action to go
    # first this action
    Write-Info "AlmostFinished"
}

Action Finished {
    Write-Info "Finished"
}
    
Start-Workflow -Name HelloWorkflow -Documentation -WhatIf:$WhatIfPreference