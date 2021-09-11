[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

$HelloVariable = 'Hello'
$Hello2Variable = 'Hello2'

Action Hello -RequiredVariables HelloVariable, Hello2Variable {
    Write-Info $HelloVariable
    Write-Info $Hello2Variable
}

Action GoodBy {
    Write-Info "GoodBy"
}

Start-Workflow -Name HelloWorkflow -WhatIf:$WhatIfPreference