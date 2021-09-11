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
    [DependsOn(("Hello"))]param()
    Write-Info "GoodBy"
}

# use functions with dependencies
Start-Workflow GoodBy -Name Hello -WhatIf:$WhatIfPreference