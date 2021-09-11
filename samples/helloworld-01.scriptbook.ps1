[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

if (!(Get-Module Scriptbook -ListAvailable -ErrorAction Ignore))
{
    Install-Module -Name Scriptbook -Repository PSGallery -Scope CurrentUser -AllowClobber
}

Action Hello {
    Write-Info "Hello"
}

Action GoodBy {
    Write-Info "GoodBy"
}

Start-Workflow -Name 'Hello-Workflow' -WhatIf:$WhatIfPreference