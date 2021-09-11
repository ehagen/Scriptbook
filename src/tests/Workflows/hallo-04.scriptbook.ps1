[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

Import-Module ../../Scriptbook/Scriptbook.psm1 -Force

function Invoke-Hello
{
    Write-Info "Hello"
}

function Invoke-GoodBy
{
    Write-Info "GoodBy"
}

Start-Workflow Hello, GoodBy -Name Hello -WhatIf:$WhatIfPreference