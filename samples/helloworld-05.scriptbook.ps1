[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

if (!(Get-Module Scriptbook -ListAvailable -ErrorAction Ignore))
{
    Install-Module -Name Scriptbook -Repository PSGallery -Scope CurrentUser -AllowClobber
}

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