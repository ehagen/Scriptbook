[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

Action Hello {
    . ./nested-02.scriptbook.ps1
}

Action GoodBy {
    . ./nested-02.scriptbook.ps1
    # TODO !!EH Convert to Start-Scriptbook ./nested-03.scriptbook.ps1
    Invoke-PSake ./nested-03.scriptbook.ps1
}

Start-Workflow -Name HelloNestedWorkflow -WhatIf:$WhatIfPreference