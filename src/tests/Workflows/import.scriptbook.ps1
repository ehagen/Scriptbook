[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force
Import-Action ./import.actions.ps1

Start-Workflow -Name ImportWorkflow -WhatIf:$WhatIfPreference