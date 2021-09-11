[CmdletBinding(SupportsShouldProcess = $True)]
Param(
    $FirstParam = 'First',
    $SecondParam = 'Second'
)

Set-Location $PSScriptRoot

if (!(Get-Module Scriptbook -ListAvailable -ErrorAction Ignore))
{
    Install-Module -Name Scriptbook -Repository PSGallery -Scope CurrentUser -AllowClobber
}

Step Hello {
    Write-Info "Hello $FirstParam"
}

Step GoodBy {
    Write-Info "GoodBy $SecondParam, I am skipped"
}

# use Steps to start workflow, use step keyword instead of action, but prevent Goodby step by ! operator
Start-Workflow -Steps Hello, !Goodby -Name 'Hello-Workflow' -WhatIf:$WhatIfPreference