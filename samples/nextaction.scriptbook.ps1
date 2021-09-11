[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

if (!(Get-Module Scriptbook -ListAvailable -ErrorAction Ignore))
{
    Install-Module -Name Scriptbook -Repository PSGallery -Scope CurrentUser -AllowClobber
}

Action Hello -NextAction Goodby2 {
    Write-Info "Hello"
}

Action GoodBy1 {
    Write-Info "GoodBy1"
}

Action GoodBy2 {
    Write-Info "GoodBy2"
}

Action GoodBy3 {
    Write-Info "GoodBy3"
}

Start-Workflow -Name HelloWorkflow -WhatIf:$WhatIfPreference