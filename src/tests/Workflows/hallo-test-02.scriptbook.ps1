Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

. ./hallo-test-02.actions.ps1

Start-Workflow -Name Hello
