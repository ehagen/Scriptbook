[CmdletBinding(SupportsShouldProcess = $True)]
Param()

Set-Location $PSScriptRoot

if (!(Get-Module Scriptbook -ListAvailable -ErrorAction Ignore))
{
    Install-Module -Name Scriptbook -Repository PSGallery -Scope CurrentUser -AllowClobber
}

Import-Action ./import.actions.ps1

Start-Workflow -Name ImportWorkflow -WhatIf:$WhatIfPreference